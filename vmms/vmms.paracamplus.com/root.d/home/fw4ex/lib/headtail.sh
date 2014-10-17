#!/bin/bash 

DEFAULTN=5

usage () {
    echo "$0 -N < someInput
outputs the first N and last N lines of the input stream.
By default N is $DEFAULTN."
    exit 1
}

if [ $# -eq 1 ]
then
    N=${1#-}
    if [ "$N" -le 0 ]
    then
        echo "$N should be positive"
        exit 1
    fi
else
    N=$DEFAULTN
fi

awk "
BEGIN   { n=${N} ; c=0 ; for (i=1;i<=n;i++) { line[i]=\"\" } }
NR<=n   { print }
n<NR    { for (i=2;i<=n;i++) { line[i-1]=line[i] }; line[n]=\$0; c++; next }
END     { if ( c < n ) {
            for (i=1; i<=c ;i++) { print line[n-c+i] }
          } else {
            for (i=1; i<=n; i++) { print line[i] }
          } }
" 

# end
