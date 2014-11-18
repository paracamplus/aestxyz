#! /bin/bash
# This script should be run as root on a marking slave.

source $HOME/fw4exrootlib/commonLib.sh

log ${0##*/}

for a in /home/student*
do
    if [[ -d $a ]]
    then
        $HOME/fw4exrootlib/clean-student.sh $a
    fi
done

# end of clear-students.sh
