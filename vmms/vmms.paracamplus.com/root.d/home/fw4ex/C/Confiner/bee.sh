#! /bin/bash
# $Id: bee.sh 140 2007-06-01 15:54:59Z queinnec $
# Busily work for some duration

usage() {
    echo "Usage: bee [-v] duration
busily works for duration seconds
  -v outputs some data
  -l splits the output in lines
" 
    exit 1
}

VERBOSE=false
SPLIT=false
DURATION=10
while [[ $# > 0 ]]
do
  case "$1" in
      -v) 
          VERBOSE=true
          shift
          ;;
      -l)
          SPLIT=true
          shift
          ;;
      *)
          DURATION="$1"
          break
          ;;
  esac
done

{ 
    typeset -i i=0
    while [[ 0 == 0 ]]
    do
      i=$(( $i+1 ))
      if $VERBOSE
      then 
          echo -n "[$i]"
          # @coucou: 1 second => i = 1 .. 9329
          if $SPLIT
          then 
              # Vary a little line lengths!
              case "$i" in
                  *00|*15|*29|*41|*55|*77|*91)
                      echo
                      ;;
              esac
          fi
      fi
    done
} & { 
    bee=$!
    sleep $DURATION
    kill -9 $bee
}

# end of bee.sh
