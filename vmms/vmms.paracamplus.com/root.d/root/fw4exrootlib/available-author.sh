#! /bin/bash -e
# This script is ran as root in the msVM (marking slave VM).
# Find (or create) an author account. 
# Their public keys are already stored under /opt/md.*/.ssh/
# EXERCISEID qualifies the exercise.
# JOBID qualifies the job.
# The result is the username of an author followed by old or new depending
# on whether the exercise is already deployed under the author HOME.

source $HOME/fw4exrootlib/commonLib.sh

# FUTURE: store stderr, race condition if invoked concurrently!

EXERCISEID=$1
JOBID=$2

log ${0##*/} $EXERCISEID for $JOBID

# Find if an already created author contains the same exercise but
# only if correctly deployed and initialized:
if [[ -f $EXERCISE_CACHE_DIR/$EXERCISEID/exercise.sh.OK ]]
then
    # Mark the exercise as being necessary:
    touch $EXERCISE_CACHE_DIR/$EXERCISEID/author
    touch $EXERCISE_CACHE_DIR/$EXERCISEID/$JOBID.job
    AUTHOR=$(cat $EXERCISE_CACHE_DIR/$EXERCISEID/author)
    log ${0##*/} $EXERCISEID for $JOBID "author ($AUTHOR) already available!"
    echo $AUTHOR old
    exit
fi

# If no exercise is deployed then, no job should be present.
N=$( cd $EXERCISE_CACHE_DIR/ ; 
     ls -1d ????????-????-????-????-???????????? 2>/dev/null | wc -l )
if [ $N -eq 0 ]
then
    # No deployed exercise so no job should be present
    ls -1d $JOB_DIR/????????-????-????-????-???????????? 2>/dev/null |\
    while read d 
    do
        log ${0##*/} Removing weird job ${d##*/}
        rm -rf $d
    done
fi

# Function adapted from users.sh
recreate_user () {
    local U=$1
    local GECOS="FW4EX Author ${U#author}"
    # deluser, adduser are Perl scripts that warn if not in C locale:
    export LANG=C

    if grep -q "$U" < /etc/passwd 
    then deluser --quiet --remove-home $U
    fi
    if grep -q "$U" < /etc/group
    then if delgroup --quiet $U
        then :
        else
            echo "WARNING: No longer in /etc/group: $U" 1>&2
        fi
    fi
    adduser --quiet --shell /bin/bash \
            --disabled-password \
            --gecos "$GECOS" \
            $U
    ( cd /home/$U/ && rm -f .bash_logout .bash_profile .bashrc )
    # HOME should be traversable by sshd:
    chmod 711 /home/$U

    # Install public key:
    mkdir /home/$U/.ssh
    cp -p /root/.ssh/$U.pub /home/$U/.ssh/authorized_keys
    chmod 511 /home/$U/.ssh/
    chmod 444 /home/$U/.ssh/authorized_keys
}

for i in $(seq -w 1 $AUTHORS_MAX_NUMBER)
do 
    if grep -q "author$i" < /etc/passwd 
    then if [[ ! -d /home/author$i ]]
        then
            deluser --quiet --remove-home author$i
        fi
    else
        AUTHOR=author$i
        break
    fi
done
if [[ -z "$AUTHOR" ]]
then 
    echo "No available author!" 1>&2
    exit 51
fi

recreate_user $AUTHOR

# Prepare a temporary directory for the exercise:
mkdir -p $EXERCISE_CACHE_DIR/$EXERCISEID/
# MD must be able to write the exercise.tgz within that directory as root@msVM
# root@msVM must be able to write in this directory see initialize-exercise.sh
# 
chown root:fw4ex $EXERCISE_CACHE_DIR/$EXERCISEID/
chmod 771 $EXERCISE_CACHE_DIR/$EXERCISEID/
echo $AUTHOR > $EXERCISE_CACHE_DIR/$EXERCISEID/author
if [ ! -f $EXERCISE_CACHE_DIR/$EXERCISEID/author ]
then 
    echo "Cannot create $EXERCISE_CACHE_DIR/$EXERCISEID/author" 1>&2
    exit 52
fi
touch $EXERCISE_CACHE_DIR/$EXERCISEID/$JOBID.job
chown $AUTHOR:fw4ex $EXERCISE_CACHE_DIR/$EXERCISEID/author
chmod 444 $EXERCISE_CACHE_DIR/$EXERCISEID/author
mkdir -p $EXERCISE_CACHE_DIR/$EXERCISEID/tmp
chmod 700 $EXERCISE_CACHE_DIR/$EXERCISEID/tmp
chown -R $AUTHOR:$AUTHOR $EXERCISE_CACHE_DIR/$EXERCISEID/tmp

# Give back to the caller the name of the author where is deployed
# the author's submission (this identity is also stored in
# $EXERCISE_CACHE_DIR/$EXERCISEID/author):

echo $AUTHOR new

# end of available-author.sh
