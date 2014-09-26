#! /bin/bash

patchYMLfile () {
    local FILE=$1
    if [ -f $FILE ]
    then
        if grep -Eiq 'version *: *([0-9]+)?' < $FILE
        then
            echo "Patching $FILE"
# Attention a ne pas changer VMversion:
            sed -r -i.bak \
   -e "/^ *version *:/s=version *: *[0-9]+ *\$=version: $VERSION=" $FILE
            sed -r -i.bak \
   -e "/^ *VERSION *:/s=VERSION *: *[0-9]+ *\$=VERSION: $VERSION=" $FILE
            echo "After patching $FILE:"
            grep -Ei 'version *: *[0-9]+ *$' $FILE
        else
            echo "No need to patch $FILE"
        fi
    fi
}

patchTXTfile () {
    local FILE=$1
    if [ -f $FILE ]
    then
        if grep -Eiq 'version *: *([0-9]+)?' < $FILE
        then
            echo "Patching $FILE"
            sed -r -i.bak \
   -e "/ *version *:/s=version *: *[0-9]+ *\$=version: $VERSION=" $FILE
            sed -r -i.bak \
   -e "/ *VERSION *:/s=VERSION *: *[0-9]+ *\$=VERSION: $VERSION=" $FILE
            echo "After patching $FILE:"
            grep -Ei 'version *: *[0-9]+ *$' $FILE
        else
            echo "No need to patch $FILE"
        fi
    fi
}

patchSHfile () {
    local FILE=$1
    if [ -f $FILE ]
    then
        if egrep -q 'VERSION=(\d+)?' < $FILE
        then
            echo "Patching $FILE"
            perl -i.bak -p -e "
s/VERSION=(\d+)?/VERSION=$VERSION/;
" $FILE
        else
            echo "No need to patch $FILE"
        fi
    fi
}

patchPerlfile () {
    local FILE=$1
    if [ -f $FILE ]
    then
        if egrep -q 'VERSION\s*=\s*(\d+)?' < $FILE
        then
            echo "Patching $FILE"
            perl -i.bak -p -e "
s/VERSION\s*=\s*(\d+)/VERSION = $VERSION/;
" $FILE
        else
            echo "No need to patch $FILE"
        fi
    fi
}

# end of preparelib.sh
