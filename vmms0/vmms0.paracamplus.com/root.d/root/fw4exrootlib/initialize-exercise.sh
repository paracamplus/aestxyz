#! /bin/bash 
# EXERCISEID is an UUID that qualifies the exercise.

source $HOME/fw4exrootlib/commonLib.sh

AUTHOR=$1
EXERCISEID=$2

# Error codes:
#  111 Missing fw4ex.xml
#  112 cannot generate init.sh
#  113 empty init.sh
#  114 ill-run init.sh
#  115 cannot generate exercise.sh
#  116 empty exercise.sh

# Left files:
#  in $EXERCISE_CACHE_DIR/$EXERCISEID/
#       init.sh
#       exercise.sh
#       exercise.sh.OK
#       out.xml       # stdout of init.sh
#       err.txt       # stderr of init.sh
#       initialize-exercise.sh.out  # stdout of this script
#       initialize-exercise.sh.err  # stderr of this script
#       errcode.txt                 # errcode of this script
# If the exercise is correctly deployed then errcode.txt does not exist
# and exercise.sh.OK exists.

log ${0##*/} $AUTHOR $EXERCISEID

# Other global variables:

EXERCISE_SCRIPT=$EXERCISE_CACHE_DIR/$EXERCISEID/exercise.sh
INITIALIZE_SCRIPT=$EXERCISE_CACHE_DIR/$EXERCISEID/init.sh

if [[ -f $EXERCISE_SCRIPT.OK ]]
then
    log ${0##*/} $AUTHOR $EXERCISEID "already initialized!"
    exit
fi
echo 0 >$EXERCISE_CACHE_DIR/$EXERCISEID/errcode.txt

# Derived globals:
# Where to find the inflated tgz of the exercise:
EXERCISEDIR=/home/$AUTHOR

# Preserve errors if any: store outputs in 1>$PREFIX.out 2>$PREFIX.err
PREFIX=$EXERCISE_CACHE_DIR/$EXERCISEID/${0##*/}

if [[ ! -f $EXERCISEDIR/fw4ex.xml ]]
then
    ERRCODE=111
    echo "Missing $EXERCISEDIR/fw4ex.xml file!" 1>>$PREFIX.err
    echo $ERRCODE >$EXERCISE_CACHE_DIR/$EXERCISEID/errcode.txt
    exit $ERRCODE
fi

# Generate the initialization script:
{
    export PERL5LIB=/home/fw4ex/fw4experllib
    echo 0 >$EXERCISE_CACHE_DIR/$EXERCISEID/errcode.txt
    if fw4exrootlib/exercise-xml2sh-init.pl \
        --maxcpu $AUTHOR_MAXCPU \
        --maxout $AUTHOR_MAXOUT \
        --maxerr $AUTHOR_MAXERR \
        --input $EXERCISEDIR/fw4ex.xml \
        --output $INITIALIZE_SCRIPT </dev/null \
        1>>$PREFIX.out 2>>$PREFIX.err
    then
        #log ${0##*/} "Generation of ${INITIALIZE_SCRIPT##*/}"
        :
    else
        ERRCODE=$? # Lost real error code!
        echo "Problem compiling $EXERCISEDIR/fw4ex.xml into $INITIALIZE_SCRIPT, code=$ERRCODE" 1>>$PREFIX.err
        ERRCODE=112
        echo $ERRCODE >$EXERCISE_CACHE_DIR/$EXERCISEID/errcode.txt
        exit $ERRCODE
    fi
    if [[ ! -f $INITIALIZE_SCRIPT ]]
    then
        echo "Problem cannot compile $EXERCISEDIR/fw4ex.xml into $INITIALIZE_SCRIPT, code=$ERRCODE" 1>>$PREFIX.err
        ERRCODE=112
        echo $ERRCODE >$EXERCISE_CACHE_DIR/$EXERCISEID/errcode.txt
        exit $ERRCODE
    fi
}

log ${0##*/} $AUTHOR $EXERCISEID generated $INITIALIZE_SCRIPT!

if [[ ! -s $INITIALIZE_SCRIPT ]]
then 
    ERRCODE=113
    echo "Empty $INITIALIZE_SCRIPT!" 1>>$PREFIX.err
    echo $ERRCODE >$EXERCISE_CACHE_DIR/$EXERCISEID/errcode.txt
    exit 113
fi

# Run the initializing script:
{
    FW4EXLIBDIR=/home/fw4ex/fw4exlib
    TMPDIR=$EXERCISE_CACHE_DIR/$EXERCISEID/tmp
    mkdir -p $TMPDIR
    chown $AUTHOR:root $TMPDIR
    chmod 760 $TMPDIR
    # These directories are for author's convenience:
    echo "export FW4EX_LIB_DIR=/home/fw4ex/lib"
    echo "export FW4EX_BIN_DIR=/home/fw4ex/bin"
    # NOTE: /home/fw4ex/fw4ex*lib/ are only for FW4EX so don't export it!
    echo "FW4EX_SPLIB_DIR=$FW4EXLIBDIR"
    echo "FW4EX_AUTHOR_CONFINE_FLAGS='--cpu=5 --maxout=100k --maxerr=100k'"
    # Other variables for author scripts:
    echo "export TMPDIR=$TMPDIR"
    echo "export FW4EX_EXERCISE_ID=$EXERCISEID"
    echo "export FW4EX_EXERCISE_DIR=$EXERCISEDIR"
    #set -x
    cat $INITIALIZE_SCRIPT
} | (
    # Setup general limitations for author's scripts!
    # FUTURE: specific limitations may come from the db for that exercise ???
    . fw4exrootlib/confine-author.sh </dev/null
    echo 0 >$EXERCISE_CACHE_DIR/$EXERCISEID/errcode.txt
    # Run author's initialization script under author's identity:
    su - $AUTHOR 3>$EXERCISE_CACHE_DIR/$EXERCISEID/out.xml \
                 4>>$EXERCISE_CACHE_DIR/$EXERCISEID/err.txt
    ERRCODE=$?
    if [[ $ERRCODE -ne 0 ]]
    then 
        echo "Initialization script exit code is $ERRCODE!" 1>&2
        echo $ERRCODE >$EXERCISE_CACHE_DIR/$EXERCISEID/errcode.txt
    fi
) 1>>$PREFIX.out 2>>$PREFIX.err

ERRCODE=$(< $EXERCISE_CACHE_DIR/$EXERCISEID/errcode.txt)

log ${0##*/} $AUTHOR $EXERCISEID after $INITIALIZE_SCRIPT, code=$ERRCODE
if [[ $ERRCODE -ne 0 ]]
then
    echo "Could not run init.sh, code=$ERRCODE" 1>>$PREFIX.err
    echo $ERRCODE >$EXERCISE_CACHE_DIR/$EXERCISEID/errcode.txt
    exit 114
fi

# Remove empty files. If they are left, these files will be caught by
# the MD server (marking driver) and appropriately routed to the
# author or to the fw4ex maintaineer. Don't remove the
# $EXERCISE_CACHE_DIR/$EXERCISEID/out.xml file since it will be inserted in
# jobStudentReport.

if [[ ! -s $EXERCISE_CACHE_DIR/$EXERCISEID/err.txt ]]
then rm -f $EXERCISE_CACHE_DIR/$EXERCISEID/err.txt
fi

# Generate the grading script:
ERRCODE=115
# The PERL5LIB is for the sake of exercise-xml2sh:
PERL5LIB=/home/fw4ex/fw4experllib \
  fw4exrootlib/exercise-xml2sh.pl \
    --maxcpu $AUTHOR_MAXCPU \
    --maxout $AUTHOR_MAXOUT \
    --maxerr $AUTHOR_MAXERR \
    --input $EXERCISEDIR/fw4ex.xml \
    --output $EXERCISE_SCRIPT </dev/null 1>>$PREFIX.out 2>>$PREFIX.out
ERRCODE=$?
if [[ $ERRCODE -ne 0 ]]
then 
    echo "Cannot generate $EXERCISE_SCRIPT, code=$ERRCODE" 1>>$PREFIX.err
    echo $ERRCODE >$EXERCISE_CACHE_DIR/$EXERCISEID/errcode.txt
    exit 115
fi

log ${0##*/} $AUTHOR $EXERCISEID generated $EXERCISE_SCRIPT

if [[ ! -s $PREFIX.out ]]
then rm -f $PREFIX.out
fi

if [[ ! -s $PREFIX.err ]]
then rm -f $PREFIX.err
fi

if [[ ! -s $EXERCISE_SCRIPT ]]
then
    ERRCODE=116
    echo "Problem while generating $EXERCISE_SCRIPT!" 1>>$PREFIX.err
    echo $ERRCODE >$EXERCISE_CACHE_DIR/$EXERCISEID/errcode.txt
    exit $ERRCODE
fi

if [[ $ERRCODE -eq 0 ]]
then
    rm -f $EXERCISE_CACHE_DIR/$EXERCISEID/errcode.txt
    touch $EXERCISE_SCRIPT.OK
fi

exit $ERRCODE

# end of initialize-exercise.sh
