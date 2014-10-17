#! /bin/bash -e
# Find (or create) a student account.
# Their public keys are already stored under ~root/.ssh/
# UUID qualifies the job.

source $HOME/fw4exrootlib/commonLib.sh

UUID=$1

log ${0##*/} $UUID

# FIXME function adapted from users.sh
recreate_user () {
    local U=$1
    local GECOS="FW4EX Student ${U#student}"

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

prepare_directories () {
    local U=$1

    # prepare tmp and results directories:
    # All files are stored under $JOB_DIR/$UUID/
    #  ./student contains the identity of the account where is deployed the job
    #  ./tmp/ is the TMPDIR 
    #  ./results/ will contain the results of the job

    mkdir -p $JOB_DIR/$UUID
    echo $U > $JOB_DIR/$UUID/student
    chmod 444 $JOB_DIR/$UUID/student
    chmod 711 $JOB_DIR/$UUID/

    mkdir $JOB_DIR/$UUID/tmp
    chmod 700 $JOB_DIR/$UUID/tmp
    chown -R $U:$U $JOB_DIR/$UUID

    mkdir $JOB_DIR/$UUID/results
    chmod 700 $JOB_DIR/$UUID/results
    chown root:root $JOB_DIR/$UUID/results
}

for i in $(seq -w 1 $STUDENTS_MAX_NUMBER)
do
    if grep -q "student$i" < /etc/passwd 
    then :
    else
        STUDENT=student$i
        break
    fi
done
if [[ -z "$STUDENT" ]]
then 
    echo "No available student!" 1>&2
    exit 52
fi

recreate_user $STUDENT
prepare_directories $STUDENT

# Give back to the caller, the name of the student where is deployed
# the student's submission (this identity is also stored in
# $JOB_DIR/$UUID/student).
echo $STUDENT

# end of available-student.sh
