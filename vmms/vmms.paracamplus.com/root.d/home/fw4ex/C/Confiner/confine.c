/* $Id: confine.c 191 2008-01-21 09:26:35Z queinnec $

Exec a program in a limited context hiding much of the current environment.
For more information, run
        confine --help
        confine --error-codes
*/

#ifdef __APPLE_CC__
#else
#define _GNU_SOURCE
#define _BSD_SOURCE
#endif

#include <stdlib.h>
#include <stdio.h>
#include <signal.h>
#include <unistd.h>
#include <string.h>
#include <assert.h>
#include <sys/resource.h>
#include <sys/time.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <errno.h>
#include <fcntl.h>
#include <limits.h>
#include <grp.h>

#include "confine.h"

/* {{{ Information reporting
 
   Error and information messages are sent onto channel 3 if available
   so they might be used by fw4ex without impacting the stdout and
   stderr of the confining (and confined) processes.
*/

static char* version = "confine 2013Mar15 09:56";
static int verbose = DEFAULT_VERBOSE_VALUE;
static FILE *fw4ex_chanout = NULL;
static FILE *exit_file_chan_out = NULL;
static char **environment;
#define is_fw4ex_chanout_correct() (fw4ex_chanout!=NULL)
static uid_t ruid;
static gid_t rgid;
static pid_t confiner_pid;

void
print_version () 
{
     printf("%s\n", version);
}

void
print_options ()
{
     print_version();
     puts(
"FW4EX options: \n"
"  --version \n"
"  --error-codes \n"
"  --help \n"

"  --exit-file somefile.txt \n"
"        file where will be stored the return code of the confined command \n"
"        error codes are stored with a final newline. \n"

"  --cpu=NN \n"
"        limit the computation to NN real seconds \n"
"  --filesize=NN \n"
"        largest file to be created \n"
"  --maxout=NN \n"
"        maximal number of bytes to be emitted on stdout \n"
"  --maxerr=NN \n"
"        maximal number of bytes to be emitted on stderr \n"
" Abbreviations such as k (1000) and M (1000*1000) are recognized. \n"

"  --append-dot-to-path \n"
"  --prepend-dot-to-path \n"
"  --append-pwd-to-path \n"
"  --prepend-pwd-to-path \n"
"  --hide prefix \n"
"        hide all environment variables whose name start with prefix \n"
"   --fw4ex-hide \n"
"        hide all environment variables starting with FW4EX or fw4ex \n"
"  --log somefile.log \n"
"        for debug \n"
"  --suspend \n"
"        for debug \n"
"  -v --verbose \n"
"        for verbose debug (more than one is possible) \n"
          );
}

void
print_error_codes () 
{
     print_version();
     puts(
"FW4EX error codes: \n"
"  209 Unknown option:  \n"
"  210 Missing program name! \n"
"  211 Failed exec()! \n"
"  212 Missing equal sign in environment! \n"
"  213 Failed setsid()! \n"
"  214 Missing number in option! \n"
"  215 Extraneous characters after number in option! \n"
"  216 Received unknown signal! \n"
"  217 Confined process's unknown exit value \n"
"  218 Failed sigaction() - SIGXXX \n"
"  219 Failed setitimer()! \n"
"  220 Failed waitpid()! \n"
"  221 Failed fork()! \n"
"* 222 Confined process did not exit by itself! \n"
"  223 Failed pipe() - stdXXX \n"
"  224 Failed dup2() - child stdXXX \n"
"  225 Failed close() - child stdXXX \n"
"  226 Failed read()! \n"
"  227 Failed write()! \n"
"* 228 Too much output! \n"
"  229 Weird child death! \n"
"  230 Failed malloc()! \n"
"  231 Failed fopen() - for XXX! \n"
"  232 Failed unsetenv()! \n"
"  233 Failed reset groups \n"
" \n"
"The exit value of this program may be: \n"
"  222 if the confined program was killed because it exceeds its specified \n"
"      duration \n"
"  228 if the confined program was killed because it exceeds the number  \n"
"      of characters to be output on its stdout or stderr streams. \n"
"  the exit value of the confined process if it terminates naturally. \n"
" \n"
"Except 222 and 228, exit values in the range 209-232 are internal errors \n"
"that normally should not be seen! \n"
          );
}

#ifndef NDEBUG
#  define debug_info(msg) info(msg)
#  define child_debug_info(msg) info(msg)
#else
#  define debug_info(msg) /* nothing */
#  define child_debug_info(msg) /* nothing */
#endif
static void info(char* msg);
static void error_exit(int code, char *msg);

void
switch_fw4ex_chanout (FILE *out) 
{
     debug_info("Switching channel3");
     if (NULL != fw4ex_chanout) {
          if (fclose(fw4ex_chanout) < 0) {
               error_exit(224, "Failed fclose()");
          }
     }
     fw4ex_chanout = out;
}

/*
  Store the exit value in a file (specified by option --exit-file).
  
  If the exit-code was set up by the confiner then it is recorded with
  a trailing newline. If this is just the exit-code of the confined
  process, no newline is appended at all.
 */

typedef enum exit_value_type {
     CONFINEE_CODE = 0x44,
     CONFINER_CODE = 0x55
} exit_value_type;

void
store_exit_value (int exit_value, exit_value_type evt)
{
     assert(confiner_pid == getpid()); /* only invoked by confiner */
     if (NULL != exit_file_chan_out) {
          /* critical section */
          switch (evt) {
               case CONFINEE_CODE: {
                    fprintf(exit_file_chan_out, "%d", exit_value);
                    break;
               }
               case CONFINER_CODE: {
                    fprintf(exit_file_chan_out, "%d\n", exit_value);
                    break;
               }
          }
          fclose(exit_file_chan_out);
          exit_file_chan_out = NULL;
     }
}

void
error_exit (int code, char *message)
{
     assert(confiner_pid == getpid()); /* only invoked by confiner */
     store_exit_value(code, CONFINER_CODE);
     /* Record that the previous error code was produced by fw4ex.  FIXME */
     if (verbose && is_fw4ex_chanout_correct()) {
          if (errno != 0) {
               fprintf(fw4ex_chanout, "[FW4EX(pid=%d):%d] %s\n\tcause: %s\n", 
                       getpid(), code, message, strerror(errno));
               errno = 0;
          } else {
               fprintf(fw4ex_chanout, "[FW4EX(pid=%d):%d] %s\n", 
                       getpid(), code, message);
          }
     }
     fflush(NULL); /* flush all output streams */
     exit(code);
}

void
info (char *message) 
{
     if (verbose>1 && is_fw4ex_chanout_correct()) {
          if (errno != 0) {
               fprintf(fw4ex_chanout, "[FW4EX(pid=%d):info] %s\n\tcause: %s\n", 
                       getpid(), message, strerror(errno));
               errno = 0;
          } else {
               fprintf(fw4ex_chanout, "[FW4EX(pid=%d):info] %s\n", 
                       getpid(), message);
          }
          fflush(NULL); /* flush all output streams */
     }
}

/* }}} {{{ Pipes

   The watchdog monitors the stdout and stderr of the confined
   process: the child process.
*/

#define PIPE_IN  0
#define PIPE_OUT 1

static int shared_out_fd[2];
static int shared_err_fd[2];

void
prepare_pipes () 
{
     errno = 0;
     if (pipe(shared_out_fd) < 0) {
          error_exit(223, "Failed pipe() - stdout!");
     }
     errno = 0;
     if (pipe(shared_err_fd) < 0) {
          error_exit(223, "Failed pipe() - stderr!");
     }
}

void
setup_child_pipes () 
{
     errno = 0;
     if (close(shared_out_fd[PIPE_IN]) < 0) {
          exit(225); /* Failed close() - child stdout! */
     }
     errno = 0;
     if (dup2(shared_out_fd[PIPE_OUT], 1) < 0) {
          exit(224); /* Failed dup2() - child stdout! */
     }
     errno = 0;
     if (close(shared_err_fd[PIPE_IN]) < 0) {
          exit(225); /* Failed close() - child stderr! */
     }
     errno = 0;
     if (dup2(shared_err_fd[PIPE_OUT], 2) < 0) {
          exit(224); /* Failed dup2() - child stderr! */
     }
}

void
child_close_superfluous_channels ()
{
     if (NULL != fw4ex_chanout) {
          if (fclose(fw4ex_chanout) < 0) {
               exit(225);
          }
     }
     if (NULL != exit_file_chan_out) {
          if (fclose(exit_file_chan_out) < 0) {
               exit(225);
          }
     }
}

struct channel {
     char *name;
     int  is_closed;
     long counter;
     int  in;
     FILE *fout;
};

static struct channel child_stdout, child_stderr;

void
setup_watchdog_pipes () 
{
     errno = 0;
     if (close(0) < 0) {
          error_exit(224, "Failed close() - watchdog stdin!");
     }

     errno = 0;
     if (close(shared_out_fd[PIPE_OUT]) < 0) {
          error_exit(224, "Failed close() - watchdog stdout!");
     }
     child_stdout.name = "out";
     child_stdout.is_closed = 0;
     child_stdout.in = shared_out_fd[PIPE_IN];
     child_stdout.fout = stdout;

     errno = 0;
     if (close(shared_err_fd[PIPE_OUT]) < 0) {
          error_exit(224, "Failed close() - watchdog stderr!");
     }
     child_stderr.name = "err";
     child_stderr.is_closed = 0;
     child_stderr.in = shared_err_fd[PIPE_IN];
     child_stderr.fout = stderr;
}

void
drain_channel (struct channel *channel)
{
     char buffer[4 * 1024];
     int incount, outcount;
     
     debug_info("Before draining...");
     while (!channel->is_closed) {
          debug_info("Before reading what to drain...");
          errno = 0;
          incount = read(channel->in, buffer, sizeof(buffer));
          if (incount < 0) {
               /* Anomaly */
               if (errno == EINTR) {
                    continue;
               }
               error_exit(226, "Failed read()!");

          } else if (incount == 0) {
               /* EOF */
               debug_info("Closing");
               channel->is_closed = 1;
               errno = 0;
               close(channel->in);
               /* TODO failed close() */
               errno = 0;
               fclose(channel->fout);
               return;

          } else {
               char *buffout = &(buffer[0]);
               int to_emit = incount;

               do {
                    debug_info("Draining...");
                    if (to_emit > channel->counter) {
                         to_emit = channel->counter;
                    }
                    errno = 0;
                    outcount = write(fileno(channel->fout), buffout, to_emit);
                    if (outcount < 0) {
                         if (errno == EINTR) {
                              continue;
                         } else if (errno == EPIPE) {
                              debug_info("Forced closing");
                              fclose(channel->fout);
                              channel->is_closed = 1;
                              close(channel->in);
                              return;
                         }
                         error_exit(227, "Failed write()!");
                    }
                    buffout += outcount;
                    to_emit -= outcount;
                    channel->counter -= outcount;
                    if (channel->counter <= 0) {
                         error_exit(228, "Too much output!");
                    }

               } while (to_emit > 0);
               /* There might be some more data to read, leave that to
                * select() inside watchdog_loop. So, don't continue,
                * just return! */
               return;
          }
     }
}

/* }}} {{{ Limits

Current limits are inherited from fw4ex to confine script authors.
They, themselves, impose tighter limits to student's programs.

 */

static rlim_t cpu_limit = 0;

void
inherit_current_limits () 
{
     struct rlimit rl = { 0, 0 };

     errno = 0;
     getrlimit(RLIMIT_CPU, &rl);
     /* FUTURE: get rid of DEFAULT_MAX_DURATION ??????????????????????? */
     cpu_limit = min(DEFAULT_MAX_DURATION, rl.rlim_max);

     errno = 0;
     getrlimit(RLIMIT_FSIZE, &rl);
     /* limit stdout and stderr to the maximal possible file size. */
     child_stdout.counter = min(rl.rlim_max, LONG_MAX);
     child_stderr.counter = child_stdout.counter;
}

void
impose_limits () 
{
     struct rlimit rl = { 0, 0 };

     /* 
        Make a new process group and make the current process the
        leader of that group. This is to make the current process
        independent of the rest of FW4EX.
     */
     errno = 0;
     if (setpgid(0, 0) < 0) {
          debug_info("Failed setpgid() - confiner");
     }
     
     /* No core dump */
     rl.rlim_max = 0;
     rl.rlim_cur = rl.rlim_max;
     errno = 0;
     if (setrlimit(RLIMIT_CORE, &rl) < 0) {
          debug_info("Failed setrlimit(RLIMIT_CORE,)!");
     }
}

/*
  This program is owned by some user but may be setuid and/or setgid
  to a more privileged user:
    getuid() returns the real user id that is, the calling user id.
    geteuid() returns the effective user id that is, the owner of 
    this program (more privileged) 
*/

/* 
   This function tries to acquire the power of the effective user/group
   if the program was setuid or setgid.

   If the program was setuid/setgid then we already have the power.
   Files are created taking euid in account.
*/

void
gain_privileges () 
{
     rgid = getgid();
     ruid = getuid();
}

/*
  This function tries to set the program as if run by the invoker (the
  real user/group id) dropping any privileges bound to the owner of
  the program that may have super powers.
*/

void
drop_privileges () 
{
     gid_t gids[1];

     gids[0] = rgid;
     setgid(gids[0]);
     setuid(ruid);

#ifdef _POSIX_SAVED_IDS
     /* Ignore errors: */
     setegid(rgid);
     seteuid(ruid);
#ifdef _GNU_SOURCE
     setresgid(rgid, rgid, rgid);
     setresuid(ruid, ruid, ruid);
#if defined(PARANOID) && PARANOID && defined(_BSD_SOURCE)
     /* abandon supplementary groups. Ignore errors ??? */
     errno = 0;
     {
          int status;
          status = setgroups(1, &(gids[0]));
          if (status != 0) {
               error_exit(233, "Failed reset groups");
          }
     }
#endif
#endif
#endif
}

/* }}} {{{ Processes and streams handling

  Try to kill all the processes in the process group of the confined
  program. If the confined program did not fork, there must be no
  process at all there.
*/

static pid_t child_pid;
static int exit_value = 217;
static exit_value_type evt = CONFINEE_CODE;
static int should_stop = 0;

void
clean_process_group ()
{
     assert(should_stop == 1);
     debug_info("Clean process group...");
     errno = 0;
     if (kill(-child_pid, SIGKILL) < 0) {
          if (errno == EPERM) {
               /* Bug in Linux kernel upto 2.6.7: ignore */
          } else if (errno != ESRCH) {
               debug_info("Failed kill()");
          }
     }
     errno = 0;
     fflush(NULL); /* flush all output streams */
}

void
handle_children_death (int options)
{
     pid_t some_pid;
     int child_status = -1;

     while (1) {
          debug_info("Starting waitpid()...");
          errno = 0;
          some_pid = waitpid(child_pid, &child_status, options);
          if (some_pid < 0) {
               /* Anomaly */
               if (errno == EINTR) {
                    continue;
               } else if (errno == ECHILD) {
                    /* No more children */
                    debug_info("No more children");
                    return;
               } else {
                    error_exit(220, "Failed waitpid()!");
               }

          } else if (some_pid == 0) {
               /* No child death! */
               debug_info("No child death!");
               return;

          } else if (some_pid == child_pid) {
               /* Whenever exit_value is filled, should_stop is true! */
               if (WIFEXITED(child_status)) {
                    exit_value = WEXITSTATUS(child_status);
                    should_stop = 1;
                    evt = CONFINEE_CODE;
                    debug_info("Got child's exit_value");
               } else {
                    exit_value = 222;
                    should_stop = 1;
                    evt = CONFINER_CODE;
                    debug_info("Child was kill()ed!");
               }
               store_exit_value(exit_value, evt);

          } else {
               /* Another child died ? */
               error_exit(229, "Weird child death!");
          }
     }
}

void
watchdog_loop () 
{
     int status;
     fd_set readfds, writefds, exceptfds;
     struct timeval t;

     while (!should_stop) {
          int channels_number = 0;
          int nfds = 2; /* fileno(stderr) */
     
          debug_info("WatchDog loop...");
          /* every 0.1 second: */
          t.tv_usec = 1000 * 100; /* microsecond */
          t.tv_sec = 0;  /* second */

          FD_ZERO(&readfds);
          FD_ZERO(&writefds);
          FD_ZERO(&exceptfds);
          if (!child_stdout.is_closed) {
               FD_SET(child_stdout.in, &readfds);
               nfds = max(nfds, child_stdout.in);
               channels_number++;
          }
          if (!child_stderr.is_closed) {
               FD_SET(child_stderr.in, &readfds);
               nfds = max(nfds, child_stderr.in);
               channels_number++;
          }
          /* FD_SET(fileno(stdout), &writefds); */
          /* FD_SET(fileno(stderr), &writefds); */

          errno = 0;
          if (channels_number > 0) {
               status = select(nfds+1, &readfds, &writefds, &exceptfds, &t);
               if (status < 0) {
                    if (errno == EINTR) {
                         continue;
                    }
                    error_exit(226, "Failed select()!");
               }
               if (FD_ISSET(child_stdout.in, &readfds)) {
                    drain_channel(&child_stdout);
               }
               if (FD_ISSET(child_stderr.in, &readfds)) {
                    drain_channel(&child_stderr);
               }
               handle_children_death(WNOHANG);
          } else {
               debug_info("Both confined streams closed.");
               handle_children_death(0);
          }
     }
}

/* }}} */

void
watchdog_signal_handler (int signum) 
{
      if (signum == SIGCHLD) {
          /* The confined process is terminated, let waitpid() get the
           exit value and exit from the confiner. */
          debug_info("Received SIGCHLD");

     } else if (signum == SIGALRM) {
          /* The confined process has not yet finished, note that 
             the watchdog should finish (and drain child output). */
          debug_info("Received SIGALRM");
          /* Whenever exit_value is filled, should_stop is true! */
          exit_value = 222;
          evt = CONFINER_CODE;
          should_stop = 1;

     } else if (signum == SIGPIPE) {
          debug_info("Received SIGPIPE");
          /* Ignore SIGPIPE so write() returns with EPIPE. */

     } else {
          errno = 0;
          error_exit(216, "Received unknown signal!");
     }
}

void
confine (int argc, char **argv)
{
     char* program;

     if (argc < 1) {
          errno = 0;
          error_exit(210, "Missing program name!");
     } else {
          program = argv[0];
     } 

     {
          int i;
          char out[4096];
          snprintf(out, 4096, "confiner(pid=%d)", getpid());
          errno = 0;
          debug_info(out);
          for ( i=0 ; i<argc ; i++ ) {
               snprintf(out, 4096, "  argument[%d]=%s", i, argv[i]);
               errno = 0;
               debug_info(out);
          }
     }

     prepare_pipes();
     drop_privileges();
     errno = 0;
     child_pid = fork();
     if (child_pid == 0) {

          /* The child runs in its own process group, so it may be
             cleaned up by the watchdog more easily. The parent process
             that runs confine will set its signal handlers only after
             forking so it does not influence the confined process.

             change user ??

             gdb trick: set follow-fork-mode child
                        set detach-on-fork off

          */
          errno = 0;
          /* try to create a new session */
          if (setsid() < 0) {
               child_debug_info("Failed setsid()!");
               errno = 0;
               /* otherwise try to create a new process group */
               if (setpgid(0, 0) < 0) {
                    child_debug_info("Failed setpgid() - child");
               }
          }
          setup_child_pipes();
          child_debug_info("About to exec()");
          child_close_superfluous_channels();
          errno = 0;
          execvp(program, argv);
          exit(211); /* Failed exec()! */

     } else if (child_pid < 0) {
          error_exit(221, "Failed fork()!");

     } else if (child_pid > 0) {

          /* Act as a watchdog monitoring the child: */
          struct itimerval it = { { 0, 0 }, { 0, 0 } };
          struct sigaction sa;
          
          debug_info("Successful fork()");
          setup_watchdog_pipes();

          it.it_value.tv_sec = cpu_limit;
          errno = 0;
          if (setitimer(ITIMER_REAL, &it, NULL) < 0) {
               error_exit(219, "Failed setitimer()!");
          }

          memset(&sa, 0, sizeof(sa));
          sa.sa_handler = watchdog_signal_handler;
          sigemptyset(&sa.sa_mask);
          sa.sa_flags = 0;
          errno = 0;
          if (sigaction(SIGALRM, &sa, NULL) < 0) {
               error_exit(218, "Failed sigaction() - sigalrm");
          }

          memset(&sa, 0, sizeof(sa));
          sa.sa_handler = watchdog_signal_handler;
          sigemptyset(&sa.sa_mask);
          sa.sa_flags = SA_NOCLDSTOP | SA_RESTART;
          errno = 0;
          if (sigaction(SIGCHLD, &sa, NULL) < 0) {
               error_exit(218, "Failed sigaction() - sigchld");
          }

          watchdog_loop();
          clean_process_group();
          fflush(NULL);
          store_exit_value(exit_value, evt);
          exit(exit_value);
     }
}

/* {{{ Front-end utilities */

/* 
   Remove from the POSIX environment all variables whose name start
   with a given prefix.

   CAUTION: unsetenv modifies env so pay attention when enumerating env.
 */

void
hide_environment_part (char* prefix, char **env) 
{
     int prefix_length = strlen(prefix);

     while ( 1 ) {
          int status;
          int found = 0;
          char **e = env;

          while (*e != NULL) {
               info(*e); /* DEBUG */
               if (!strncmp(prefix, *e, prefix_length)) {
                    char *varname = strdup(*e);
                    char *equalsign;
                    char *place;

                    equalsign = strchr(varname, '=');
                    if (equalsign != NULL) {
                         *equalsign = '\0';
                         found++;
                         status = unsetenv(varname); 
                         if ( status != 0 ) {
                              error_exit(232, "Failed unsetenv()!");
                         }
                         assert(NULL == getenv(varname));
                         place = getenv(varname);
                         if ( place != NULL ) {
                              error_exit(232, "Silently failed unsetenv()!");
                         }
                         info("\tRemoved!");
                    } else {
                         errno = 0;
                         error_exit(212, "Missing equal sign in environment!");
                    }
                    free(varname);
               }
               e++;
          }
          if ( found == 0 ) {
               return;
          }
     }
}

void 
shift (int *argc, char ***argv)
{
     (*argc)--;
     (*argv)++;
}

/**
 * Is the rank-th argument an option ? 
 * Check that rank is within the range [ 0 .. argc-1 ].
 */

char*
is_option (int rank, int *argc, char ***argv)
{
     if ( rank < *argc ) {
          char *option = (*argv)[rank];
          if ( option[0] == '-' ) {
               return ++option;
          } else {
               return NULL;
          }
     } else {
          return NULL;
     }
}

int
parse_number (char *option_name, int *argc, char ***argv) 
{
     long result;
     char *number;
     char *number_end;
     char *equal_sign = strchr(option_name, '=');

     if (equal_sign == NULL) {
          /* option value is the next argument (already shifted): */
          number = (*argv)[0];
          shift(argc, argv);
     } else {
          number = ++equal_sign;
     }
     errno = 0;
     result = strtol(number, &number_end, 0);
     if (number_end == number) {
          error_exit(214, "Missing number in option!");
     } else if ('M' == *number_end) {
          result *= 1000 * 1000;
     } else if ('k' == *number_end) {
          result *= 1000;
     } else if ('\0' != *number_end) {
          error_exit(215, "Extraneous characters after number in option!");
     }
     return result;
}

char *
get_currend_pwd ()
{
     char *pwd = NULL;
     int pwd_max_length = 512;

     pwd = malloc(pwd_max_length);
     while ( 1 ) {
          if (pwd == NULL) {
               errno = 0;
               error_exit(230, "Failed realloc() - pwd");
          }
          if ( NULL != getcwd(pwd, pwd_max_length) ) {
               break;
          }
          pwd_max_length *= 2;
          pwd = realloc(pwd, pwd_max_length);
     }
     return pwd;
}

int
start_with (char *prefix, char *s) 
{
     return !strncmp(prefix, s, strlen(prefix));
}

void
handle_one_option (char* option_name, int *argc, char ***argv)
{
     /* debug_info(option_name) ??? */

     if (   !strcmp("v", option_name)
         || !strcmp("-verbose", option_name) ) {
          verbose++;

     } else if (!strcmp("-version", option_name)) {
          print_version();
          exit(EXIT_SUCCESS);

     } else if (!strcmp("-error-codes", option_name)) {
          print_error_codes();
          exit(EXIT_SUCCESS);

     } else if (!strcmp("-help", option_name)) {
          print_options();
          exit(EXIT_SUCCESS);

     } else if (!strcmp("-append-dot-to-path", option_name)) {
          char *path = getenv("PATH");
          char *newpath = malloc(strlen(path)+2);
          if (newpath == NULL) {
               errno = 0;
               error_exit(230, "Failed malloc() - newpath");
          }
          (void) strcat(newpath, path);
          (void) strcat(newpath, ":.");
          (void) setenv("PATH", newpath, 1);

     } else if (!strcmp("-prepend-dot-to-path", option_name)) {
          char *path = getenv("PATH");
          char *newpath = malloc(strlen(path)+2);
          if (newpath == NULL) {
               errno = 0;
               error_exit(230, "Failed malloc() - newpath");
          }
          (void) strcat(newpath, ".:");
          (void) strcat(newpath, path);
          (void) setenv("PATH", newpath, 1);

     } else if (!strcmp("-append-pwd-to-path", option_name)) {
          char *path = getenv("PATH");
          char *pwd = get_currend_pwd();
          char *newpath = malloc(strlen(path)+1+strlen(pwd));
          if (newpath == NULL) {
               errno = 0;
               error_exit(230, "Failed malloc() - newpath");
          }
          (void) strcat(newpath, path);
          (void) strcat(newpath, ":");
          (void) strcat(newpath, pwd);
          (void) setenv("PATH", newpath, 1);

     } else if (!strcmp("-prepend-pwd-to-path", option_name)) {
          char *path = getenv("PATH");
          char *pwd = get_currend_pwd();
          char *newpath = malloc(strlen(pwd)+1+strlen(path));
          if (newpath == NULL) {
               errno = 0;
               error_exit(230, "Failed malloc() - newpath");
          }
          (void) strcat(newpath, pwd);
          (void) strcat(newpath, ":");
          (void) strcat(newpath, path);
          (void) setenv("PATH", newpath, 1);

     } else if (start_with("-cpu", option_name)) {
          struct rlimit rl = { 0, 0 };
          /* Per-process CPU limit, in seconds */
          rl.rlim_max = parse_number(option_name, argc, argv);
          rl.rlim_cur = rl.rlim_max;
          cpu_limit = rl.rlim_cur;
          setrlimit(RLIMIT_CPU, &rl);

     } else if (start_with("-filesize", option_name)) {
          struct rlimit rl = { 0, 0 };
          /* Largest file that can be created, in bytes */
          rl.rlim_max = parse_number(option_name, argc, argv);
          rl.rlim_cur = rl.rlim_max;
          setrlimit(RLIMIT_FSIZE, &rl);

     } else if (start_with("-maxout", option_name)) {
          /* Maximum number of bytes to be emitted on stdout */
          child_stdout.counter = parse_number(option_name, argc, argv);

     } else if (start_with("-maxerr", option_name)) {
          /* Maximum number of bytes to be emitted on stderr */
          child_stderr.counter = parse_number(option_name, argc, argv);

    /* ensure final newline ??? */

     } else if (start_with("-log", option_name)) {
          FILE *result;
          char *logfile_name = (*argv)[0];
          shift(argc, argv);
          errno = 0;
          /* The logfile is opened with euid power: */
          result = fopen(logfile_name, "a");
          if (result != NULL) {
               switch_fw4ex_chanout(result);
          } else {
               error_exit(231, "Failed fopen() - for log!");
          }

     } else if (start_with("-fw4ex-hide", option_name)) {
          char *prefix = "FW4EX";
          hide_environment_part(prefix, environment);
          prefix = "fw4ex";
          hide_environment_part(prefix, environment);

     } else if (start_with("-hide=", option_name)) {
          error_exit(209, "Bad syntax for option --hide XX !");

     } else if (start_with("-hide", option_name)) {
          char *prefix = (*argv)[0];
          shift(argc, argv);
          hide_environment_part(prefix, environment);

     } else if (start_with("-suspend", option_name)) {
          /* let gdb attach this process */
#ifdef __APPLE_CC__
          sigset_t null_mask = { 0 };
#else
          sigset_t null_mask = { { 0 } };
#endif
          sigsuspend(&null_mask);

     } else if (start_with("-exit-file", option_name)) {
          FILE *result;
          char *exit_file_name = (*argv)[0];
          shift(argc, argv);
          {
               /* Don't check for errors when deleting the file */
               int status = unlink(exit_file_name);
               if ( status != 0 ) {
                    debug_info("Cannot delete previous exit_file");
               }
          }
          errno = 0;
          /* The exit_file is opened with euid power: */
          result = fopen(exit_file_name, "w");
          if (result != NULL) {
               exit_file_chan_out = result;
          } else {
               error_exit(231, "Failed fopen() - for exit-file!");
          }      

     } else {
          char *prefix = "Unknown option: ";
          char *msg = malloc(strlen(option_name) + strlen(prefix) + 1);
          if (msg == NULL) {
               errno = 0;
               error_exit(230, "Failed malloc() - msg");
          }
          (void) strcat(msg, prefix);
          (void) strcat(msg, option_name);
          error_exit(209, msg);
     }
}

/*
  Stop analyzing option at first word that does not look like an option.
*/

void
handle_options (int *argc, char ***argv)
{
     char *option_name;

     /* hide $0 */
     shift(argc, argv);
     /* scan options */
     while (0 < *argc) {
          option_name = is_option(0, argc, argv);
          if (option_name == NULL) {
               return;
          } else if (!strcmp("-", option_name)) {
               shift(argc, argv);
               return;
          } else {
               shift(argc, argv);
               handle_one_option(option_name, argc, argv);
          }
     }
}

/* }}} */

int
main (int argc, char **argv, char **env)
{
     confiner_pid = getpid();
     environment = env;
     gain_privileges();
     inherit_current_limits();
     handle_options(&argc, &argv);
     impose_limits();
     confine(argc, argv);
     /* NOT REACHED */
     store_exit_value(EXIT_FAILURE, CONFINER_CODE);
     return EXIT_FAILURE;
}

/* end of confine.c */
