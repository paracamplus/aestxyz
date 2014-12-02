#! /bin/sh
# This script is run as root and sets general limits for an author when
# grading a single submission. It should be sourced to be effective.

rt_ulimit () {
    if ulimit "$@"
    then :
    else
        echo "PROBLEM with ulimit $@" 1>&2
        exit 53
    fi
}

K=000
M=$K$K

# NOTE: Pay attention to the units: often 1ki page
# coucou$ ulimit -a
# core file size          (blocks, -c) 0
# data seg size           (kbytes, -d) unlimited
# scheduling priority             (-e) 0
# file size               (blocks, -f) unlimited
# pending signals                 (-i) 36864
# max locked memory       (kbytes, -l) 32
# max memory size         (kbytes, -m) unlimited
# open files                      (-n) 1024
# pipe size            (512 bytes, -p) 8
# POSIX message queues     (bytes, -q) 819200
# real-time priority              (-r) 0
# stack size              (kbytes, -s) 8192
# cpu time               (seconds, -t) unlimited
# max user processes              (-u) 36864
# virtual memory          (kbytes, -v) unlimited
# file locks                      (-x) unlimited

# m0.fw4ex.paracamplus.com# ulimit -a
# core file size          (blocks, -c) 0
# data seg size           (kbytes, -d) unlimited
# max nice                        (-e) 0
# file size               (blocks, -f) unlimited
# pending signals                 (-i) unlimited
# max locked memory       (kbytes, -l) unlimited
# max memory size         (kbytes, -m) unlimited
# open files                      (-n) 1024
# pipe size            (512 bytes, -p) 8
# POSIX message queues     (bytes, -q) unlimited
# max rt priority                 (-r) 0
# stack size              (kbytes, -s) 8192
# cpu time               (seconds, -t) unlimited
# max user processes              (-u) unlimited
# virtual memory          (kbytes, -v) unlimited
# file locks                      (-x) unlimited

# 2014nov30: removed limits on process sizes. java7 needs lots of memory!
rt_ulimit -c      0 # bloc (maximum size of core files created)
#rt_ulimit -d  900$K # 400 meg (maximum size of a process's data segment)
# -e does not seem important here ???
rt_ulimit -f   10$K # 10 meg (maximum size of files created by the shell)
rt_ulimit -i    100 # (pending signals)
rt_ulimit -l     32 # kb (max locked memory)
#rt_ulimit -m   100$K # 50 meg (maximum resident set size)
rt_ulimit -n    200 # (maximum number of open file descriptors)
#rt_ulimit -p      8 # default pipe size           # cannot modify limit!
rt_ulimit -q   10$K # 10 k (POSIX message queues)
# -r does not seem important here ???
#rt_ulimit -s   20$K # 10 meg (maximum stack size)
rt_ulimit -t    120 # 100 seconds (maximum amount of cpu time)
rt_ulimit -u    300 # maximum number of processes available to a single user
# 400k is not sufficient for java7
#rt_ulimit -v  400$K # 400 meg (virtual memory)
#rt_ulimit -v  1500$K # 1200 meg (virtual memory)
rt_ulimit -x    100 # file locks

# end of confine-author.sh
