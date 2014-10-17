/* $Id$ 

   This utility analyzes a stream of bytes (from stdin) and fixes it
   in order to output correct a UTF-8 stream. It also converts special
   XML characters, splits too long lines and aborts the whole process
   after some number of good or bad characters. In case of errors, it
   returns many different exit codes.

   For more information, run
      transcode --help

 */

#include <stdlib.h>
#include <stdio.h>
#include <getopt.h>

static int verbose = 0;
static int number_line = 0;
static int special_chars = 1;

enum STATE {
     single,
     double0,    /* prefix1 contains first byte */
     triple0,    /* prefix1 contains first byte */
     triple1,    /* prefix2 contains second byte */
     quadruple0, /* prefix1 contains first byte */
     quadruple1, /* prefix2 contains second byte */
     quadruple2  /* prefix3 contains third byte */
} state = single;

static int prefix1 = 0;
static int prefix2 = 0;
static int prefix3 = 0;

/* Emitted for a non printable single byte: */
static char* bad_char = "&#x275a;";
/* Emitted when encountering a continuation octet (10ab cdef) alone: */
static char* bad_char1 = "&#x2762;";
/* Unfinished multioctet sequence: */
static char* bad_char2 = "&#x271c;";

/* Maximal number of possible bad chars. More means abort! */
static long bad_char_limit = 100;
static long bad_char_count = 0;
/* Character to report abort transcoding: */
static char* abort_sequence = "&#x2639;&#x2639;&#x2639;";

/* Maximal number of possible good chars. More means Stop! */
static long good_char_limit = 100 * 1000;
static long good_char_count = 0;
static char* overflow_sequence = "&#x2340;&#x2340;&#x2340;";

/* Split long lines. */
static long line_char_count = 0;
static long line_char_limit = 80;
static char* cut_line_sequence = "&#x21a9;\n&#x21aa;";

/*
 * Flush all streams and finalize unfinished transcoding.
 */

void finalize () 
{
     switch ( state ) {
          case single: {
               break;
          }
          case double0: {
               printf("%s{%02X}", bad_char2, prefix1);
               break;
          }
          case triple0: {
               printf("%s{%02X}", bad_char2, prefix1);
               break;
          }
          case triple1: {
               printf("%s{%02X}{%02X}", bad_char2, prefix1, prefix2);
               break;
          }
          case quadruple0: {
               printf("%s{%02X}", bad_char2, prefix1);
               break;
          }
          case quadruple1: {
               printf("%s{%02X}{%02X}", bad_char2, prefix1, prefix2);
               break;
          }
          case quadruple2: {
               printf("%s{%02X}{%02X}{%02X}", bad_char2, 
                      prefix1, prefix2, prefix3);
               break;
          }
     }
     fflush(NULL);
}

/*
 * Is it a normal char that we may handle without problem ?
 */

int is_good_char (int c)
{
     if ( c < 128 ) {
          if ( c == 10 || c == 9 ) {
               return 1;
          } else if ( c < 32 ) {
               return 0;
          } else if ( c < 127 ) {
               return 1;
          } else {
               return 0;
          }
     } else {
          return 0;
     }
}

/* 
 * Handle an ascii character [0 - 127]
 */

void handle_ascii_char (int c)
{
     if ( verbose ) {
          fprintf(stderr, "handle_ascii_char(%02X)\n", c);
     }
     state = single;
     if ( good_char_limit > 0 && ++good_char_count > good_char_limit ) {
          printf("%s", overflow_sequence);
          exit(12);
     }
     if ( c == 10 ) { /* newline */
          putchar(c);
          line_char_count = 0;
          if ( number_line ) {
               printf("<lineNumber>%4d</lineNumber> ", number_line++);
          }
     } else {
          if ( line_char_limit > 0 && ++line_char_count > line_char_limit ) {
               printf("%s", cut_line_sequence);
               line_char_count = 1;
          }
          if ( c == 9 ) { /* tabulation */
               putchar(c);
          } else if ( c < 32 ) { /* control chars */
               bad_char_count++;
               printf("%s{%02X}", bad_char, c);
          } else if ( special_chars && c == '&' ) {
               printf("%s", "&amp;");
          } else if ( special_chars && c == '<' ) {
               printf("%s", "&lt;");
          } else if ( special_chars && c == '>' ) {
               printf("%s", "&gt;");
          } else if ( special_chars && c == 047 ) { /* ' */
               printf("%s", "&apos;");
          } else if ( special_chars && c == '"' ) {
               printf("%s", "&quot;");
          } else if ( c < 127 ) {
               putchar(c);
          } else {
               bad_char_count++;
               printf("%s{%02X}", bad_char, c);
          }
     }
}

/*

0abc defg                                     7bits
110a bcde 10fg hijk                          11bits
   1100 0000 (192) jusqu'a 1101 1111 (223)
   1000 0000 (128) jusqu'a 1011 1111 (191)
1110 abcd 10ef ghij 10kl mnop                16bits
   1110 0000 (224) jusqu'a 1110 1111 (239)
1111 0abc 10de fghi 10jk lmno 10pq rstu      21bits
   1111 0000 (240) jusqu'a 255.
See http://search.cpan.org/~nwclark/perl-5.8.9/pod/perlunicode.pod
for forbidden combinations.

*/

void transcode (int c)
{
     if ( verbose ) {
          fprintf(stderr, "transcode(%02X)\n", c);
     }
     if ( c < 128 ) {
          state = single;
          handle_ascii_char(c);
     } else if ( c < 192 ) {
          /* within [128 191] that is 10fghijk a continuation octet 
           However we are not expecting such an octet here! */
          state = single;
          bad_char_count++;
          printf("%s{%02X}", bad_char1, c);
     } else if ( c < 224 ) {
          /* within [192 223] that is 110abcde, one more octet to read */
          state = double0;
          prefix1 = c;
     } else if ( c < 240 ) {
          /* within [224 240] that is 1110abcd, two more octets to process */
          state = triple0;
          prefix1 = c;
     } else {
          /* within [240 255] that is 11110abc, three more octets to process */
          state = quadruple0;
          prefix1 = c;
     }
}

void transcodeDouble (int c)
{
     if ( verbose ) {
          fprintf(stderr, "transcodeDouble(%02X)\n", c);
     }
     if ( c < 128 || 191 < c ) {
          /* Not a continuation octet 10fghijk! */
          if ( is_good_char(c) ) {
               printf("%s{%02X}", bad_char2, prefix1);
               bad_char_count++;
               handle_ascii_char(c);
          } else {
               printf("%s{%02X}{%02X}", bad_char2, prefix1, c);
               bad_char_count++;
               state = single;
          }
     } else {
          /* state=double0, prefix1 = 110abcde, c = 10fghijk */
          putchar(prefix1);
          putchar(c);
          state = single;
     }
}

void transcodeTriple0 (int c)
{
     if ( verbose ) {
          fprintf(stderr, "transcodeTriple0(%02X)\n", c);
     }
     if ( c < 128 || 191 < c ) {
          /* Not a continuation octet 10fghijk! */
          if ( is_good_char(c) ) {
               printf("%s{%02X}", bad_char2, prefix1);
               bad_char_count++;
               handle_ascii_char(c);
          } else {
               printf("%s{%02X}{%02X}", bad_char2, prefix1, c);
               bad_char_count++;
               state = single;
          }
     } else {
          /* state=triple0, prefix1 = 1110abcd, c = 10efghij */
          prefix2 = c;
          state = triple1;
     }
}

void transcodeTriple1 (int c)
{
     if ( verbose ) {
          fprintf(stderr, "transcodeTriple1(%02X)\n", c);
     }
     if ( c < 128 || 191 < c ) {
          /* Not a continuation octet 10klmnop! */
          if ( is_good_char(c) ) {
               printf("%s{%02X}", bad_char2, prefix1);
               bad_char_count++;
               handle_ascii_char(c);
          } else {
               printf("%s{%02X}{%02X}{%02X}", bad_char2, prefix1, prefix2, c);
               bad_char_count++;
               state = single;
          }
     } else {
          /* state=triple1, prefix1 = 1110abcd, prefix2 = 10efghij, 
             c= 10klmnop */
          putchar(prefix1);
          putchar(prefix2);
          putchar(c);
          state = single;
     }
}

void transcodeQuadruple0 (int c)
{
     if ( verbose ) {
          fprintf(stderr, "transcodeQuadruple0(%02X)\n", c);
     }
     if ( c < 128 || 191 < c ) {
          /* Not a continuation octet 10defghi! */
          if ( is_good_char(c) ) {
               printf("%s{%02X}", bad_char2, prefix1);
               bad_char_count++;
               handle_ascii_char(c);
          } else {
               printf("%s{%02X}{%02X}", bad_char2, prefix1, c);
               bad_char_count++;
               state = single;
          }
     } else {
          /* state=quadruple0, prefix1 = 11110abc, c = 10defghi */
          prefix2 = c;
          state = quadruple1;
     }
}

void transcodeQuadruple1 (int c)
{
     if ( verbose ) {
          fprintf(stderr, "transcodeQuadruple1(%02X)\n", c);
     }
     if ( c < 128 || 191 < c ) {
          /* Not a continuation octet 10jklmno! */
          if ( is_good_char(c) ) {
               printf("%s{%02X}{%02X}", bad_char2, prefix1, prefix2);
               bad_char_count++;
               handle_ascii_char(c);
          } else {
               printf("%s{%02X}{%02X}{%02X}", bad_char2, prefix1, prefix2, c);
               bad_char_count++;
               state = single;
          }
     } else {
          /* state=quadruple1, prefix1 = 11110abc, prefix2 = 10defghi, 
             c = 10jklmno */
          prefix3 = c;
          state = quadruple2;
     }
}

void transcodeQuadruple2 (int c)
{
     if ( verbose ) {
          fprintf(stderr, "transcodeQuadruple2(%02X)\n", c);
     }
     if ( c < 128 || 191 < c ) {
          /* Not a continuation octet 10pqrstu! */
          if ( is_good_char(c) ) {
               printf("%s{%02X}{%02X}{%02X}", bad_char2, 
                      prefix1, prefix2, prefix3);
               bad_char_count++;
               handle_ascii_char(c);
          } else {
               printf("%s{%02X}{%02X}{%02X}{%02X}", bad_char2, 
                      prefix1, prefix2, prefix3, c);
               bad_char_count++;
               state = single;
          }
     } else {
          /* state=quadruple2, prefix1 = 11110abc, prefix2 = 10defghi, 
             prefix3 = 10jklmno, c = 10pqrstu */
          putchar(prefix1);
          putchar(prefix2);
          putchar(prefix3);
          putchar(c);
          state = single;
     }
}

static struct option longopts[] = {
     { "verbose",          no_argument,       NULL, 'v' },
     { "help",             no_argument,       NULL, 'h' },
     { "lineNumber",       no_argument,       NULL, 'l' },
     { "charHTML",         no_argument,       NULL, 'c' },
     { "bad_char_limit",   required_argument, NULL, 'b' },
     { "good_char_limit",  required_argument, NULL, 'g' },
     { "split_line_limit", required_argument, NULL, 's' },
     { NULL,               0,                 NULL, 0 }
};

void usage () 
{
     fprintf(stderr, ""
             "Usage: transcode [options...]\n"
             " Sanitize a stream of bytes into an UTF-8 respectful stream.\n"
             " Meanwhile, splits lines, aborts output over some limits.\n"
             " Options are:\n"
             "  -h   this help\n"
             "  -v   verbose output on stderr\n"
             "  -l   number lines\n"
             "  -c   don't translate XML special chars\n"
             "  --b=N at most N bad chars will be output (0 means infinity)\n"
             "  --g=N at most N good chars will be output (0 means infinity)\n"
             "  --s=N split lines after N chars (0 means infinity)\n"
          );
}

void handle_options (int argc, char *argv[])
{
     char *end = NULL;
     int ch = -1;
     while ((ch = getopt_long(argc, argv, "vhlcb:g:s:", longopts, NULL)) != -1) {
          end = optarg;
          switch (ch) {
               case 'h': {
                    usage();
                    exit(0);
               }
               case 'v': {
                    verbose++;
                    break;
               }
               case 'l': {
                    number_line = 1;
                    break;
               }
               case 'c': {
                    special_chars = 0;
                    break;
               }
               case 'b': {
                    bad_char_limit = strtol(optarg, &end, 0);
                    if ( *end != '\0' ) {
                         fprintf(stderr, "Incorrect argument for %s\n", 
                                 longopts[optind].name);
                         exit(4);
                    }
                    break;
               }
               case 'g': {
                    good_char_limit = strtol(optarg, &end, 0);
                    if ( *end != '\0' ) {
                         fprintf(stderr, "Incorrect argument for %s\n", 
                                 longopts[optind].name);
                         exit(5);
                    }
                    break;
               }
               case 's': {
                    line_char_limit = strtol(optarg, &end, 0);
                    if ( *end != '\0' || line_char_limit < 0 ) {
                         fprintf(stderr, "Incorrect argument for %s\n", 
                                 longopts[optind].name);
                         exit(6);
                    }
                    break;
               }
               case ':': {
                    // missing argument
                    fprintf(stderr, "Incorrect option!\n");
               }
               case '?': {
                    // unknown argument
                    fprintf(stderr, "Unknown option!\n");
               }
               case 0: {
                    // ?
                    fprintf(stderr, "Illegal option!\n");
               }
               default: {
                    usage();
                    exit(1);
               }
          }
     }
}

int main (int argc, char *argv[])
{
     handle_options(argc, argv);

     if ( number_line ) {
          printf("<lineNumber>%4d</lineNumber> ", number_line++);
     }

     while ( 1 ) {
          int c = getc(stdin);
          if ( feof(stdin) ) {
               break;
          }
          if ( bad_char_limit > 0 && bad_char_count > bad_char_limit ) {
               puts(abort_sequence);
               exit(13);
          }
          switch ( state ) {
               case single: {
                    transcode(c);
                    continue;
               }
               case double0: {
                    transcodeDouble(c);
                    continue;
               }
               case triple0: {
                    transcodeTriple0(c);
                    continue;
               }
               case triple1: {
                    transcodeTriple1(c);
                    continue;
               }
               case quadruple0: {
                    transcodeQuadruple0(c);
                    continue;
               }
               case quadruple1: {
                    transcodeQuadruple1(c);
                    continue;
               }
               case quadruple2: {
                    transcodeQuadruple2(c);
                    continue;
               }
          }
     }
     finalize();
}

/* end of transcode.c */
