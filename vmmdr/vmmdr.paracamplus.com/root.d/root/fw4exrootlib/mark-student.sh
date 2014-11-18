#! /bin/bash 
# Mark a single submission. This script is run as root.
# The exercise is assumed to be correct and already checked.
# JOBUUID identifies the precise job.

source $HOME/fw4exrootlib/commonLib.sh

STUDENT=$1
JOBUUID=$2
AUTHOR=$3
EXERCISEID=$4

log ${0##*/} $STUDENT $JOBUUID $AUTHOR $EXERCISEID

# Derived globals (not exported to author):

FW4EXLIBDIR=/home/fw4ex/fw4exlib
EXERCISEDIR=/home/$AUTHOR

TMPDIR=$JOB_DIR/$JOBUUID/tmp
RESULTSDIR=$JOB_DIR/$JOBUUID/results
EXERCISE_SCRIPT=$EXERCISE_CACHE_DIR/$EXERCISEID/exercise.sh
INITIALIZE_SCRIPT=$EXERCISE_CACHE_DIR/$EXERCISEID/init.sh
AUTHOR_CONFINE_FLAGS="--cpu=$AUTHOR_MAXCPU --maxout=$AUTHOR_MAXOUT --maxerr=$AUTHOR_MAXERR"

if [[ -f $EXERCISE_SCRIPT ]]
then :
else
    echo "Disappeared exercise $EXERCISE_SCRIPT!" 1>&2
    exit 120
fi

{
    if [[ $DEBUG_VERBOSITY -gt 0 ]]
    then echo "set -x"  # DEBUG
    fi
    # These directories are for author's convenience:
    echo "export FW4EX_LIB_DIR=/home/fw4ex/lib"
    echo "export FW4EX_BIN_DIR=/home/fw4ex/bin"
    # NOTE: /home/fw4ex/fw4ex*lib/ are only for FW4EX so don't export it!
    echo "FW4EX_SPLIB_DIR=$FW4EXLIBDIR"
    echo "FW4EX_AUTHOR_CONFINE_FLAGS='$AUTHOR_CONFINE_FLAGS'"
    # Other variables for author scripts:
    echo "export TMPDIR=$TMPDIR"
    echo "export FW4EX_JOB_ID=$JOBUUID"
    echo "export FW4EX_EXERCISE_ID=$EXERCISEID"
    echo "export FW4EX_EXERCISE_DIR=$EXERCISEDIR"
    # Variables leading to libraries:
    echo "export FW4EX_JUNIT_JAR=/home/fw4ex/lib/orgFW4EXjunitTest.jar"
    echo "export FW4EX_JAVA_BIN=/home/fw4ex/lib/java/bin"
    echo "export LANG=C"
    echo "export LC_ALL=C"
    cat $EXERCISE_SCRIPT
} | (
    # Setup general limitations for author's scripts!
    # FUTURE: specific limitations may come from the db for that exercise ???
    . fw4exrootlib/confine-author.sh </dev/null
    echo '<?xml version="1.0" encoding="UTF-8" ?>' > $RESULTSDIR/out.xml
    # Give to the author the errors made during exercice initialization:
    if [ -f $EXERCISE_CACHE_DIR/$EXERCISEID/err.txt ]
    then cat $EXERCISE_CACHE_DIR/$EXERCISEID/err.txt > $RESULTSDIR/err.txt
    fi
    # Run author's script under student's identity:
    su - $STUDENT 3>>$RESULTSDIR/out.xml \
                  4>>$RESULTSDIR/err.txt
) 1>>$RESULTSDIR/fw4ex-outerr.txt 2>&1

# 1> and 2> are for the benefit of FW4EX. They should be totally empty
# otherwise there are problems within FW4EX software!
# When running marking scripts written by the author:
#   3> will become 1> and will be given to the student (and the author)
#   4> will become 2> and will be given to the author.

# Insert exercise initialization report within student's report:
sed -i.BAK -e "/<FW4EX what=.initializing..>/r$EXERCISE_CACHE_DIR/$EXERCISEID/out.xml" \
    $RESULTSDIR/out.xml && rm -f $RESULTSDIR/out.xml.BAK

# Remove empty files. If they are left, these files will be caught by
# the MD server (marking driver) and appropriately routed to the
# author or to the fw4ex maintaineer.

if [[ ! -s $RESULTSDIR/err.txt ]]
then rm -f $RESULTSDIR/err.txt
fi

if [[ ! -s $RESULTSDIR/fw4ex-outerr.txt ]]
then rm -f $RESULTSDIR/fw4ex-outerr.txt
fi

# Gather the results in a single file (this is easier to transfer back
# to MD). The RESULTSDIR will be cleaned up later (see clean-student).
# To ease debug, we adjoin the exercise script to the results. It will
# be still invisible from students since it is not a part of out.xml.

# The targz is suffixed by .taz since quite often it is stored at the
# same place as job.tgz with a similar name.

cd $RESULTSDIR/
cp -p $EXERCISE_SCRIPT ./
cp -p $INITIALIZE_SCRIPT ./
cd ..
JOBTAZ=$JOBUUID.taz
log ${0##*/} about to run, in $(pwd), tar czf $JOBTAZ -C results .
if tar czf $JOBTAZ -C results .
then 
    chmod 444 $JOBTAZ
    log ${0##*/} ran successfully tar czf $JOBTAZ -C results .
    tar tzf $JOBTAZ | logdebug ${0##*/} "tar tzf $JOBTAZ"
else
    log ${0##*/} PROBLEM $? with tar czf $JOBTAZ *
fi

# end of mark-student.sh
