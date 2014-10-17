#! /bin/bash
# Cleanup a student account after marking.
# UUID identifies the job.
source $HOME/fw4exrootlib/commonLib.sh

STUDENT=$1
UUID=$2

log ${0##*/} $STUDENT $UUID

# Remove results of the job
( 
    RESULTSDIRPREFIX=$JOB_DIR/$UUID
    rm -f ${RESULTSDIRPREFIX}.tgz 
    rm -rf ${RESULTSDIRPREFIX}/
    log ${0##*/} removed ${RESULTSDIRPREFIX}*
) 2>/dev/null

# Many students use /tmp so clean it afterwards.
rm -rf $(find /tmp -user $STUDENT)

if [ -d /tmp/$UUID ]
then 
    rm -rf /tmp/$UUID
fi

# Kill all remaining processes owned by the student
PIDS=$(ps -u $STUDENT -o pid=)
if [ "$PIDS" ]
then kill -9 $PIDS
fi

deluser --quiet --remove-home $STUDENT

# end of clean-student.sh
