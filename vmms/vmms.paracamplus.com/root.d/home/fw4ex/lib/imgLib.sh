#! /bin/bash
# Additional library for authors of exercises for FW4EX.
# This library should be sourced.

#=pod

# This library defines additional functions to insert images within
# the grading report.

#=head2 fw4ex_insert_image

# This function embeds an image (designated as a file) within the
# grading report. The first argument is the file containing the image
# (png, jpeg images are well handled), the second argument is the text
# serving as ALT attribute. Attention, there are certain restriction
# on the size of the image in some browsers.

#=cut

#examples for test within the VM: 
#   /usr/share/plt/doc/search/slidey.png
#   /usr/lib/plt/collects/icons/plt.jpg

fw4ex_insert_image () {
    local FILE="$1"
    local ALT="$(echo $2 | fw4ex_transcode_carefully)"
    echo "<img alt='$ALT' "
    local MIMETYPE="$(file -b --mime-type $FILE)"
    case "$MIMETYPE" in 
        image/png)
            set `file -b $FILE | perl -pe 's/^.*, (\d+) x (\d+),.*$/$1 $2/'`
            echo " width='$1' height='$2' "
            ;;
        image/jpeg)
            #set `identify $FILE`
            # ImageMagick should be installed in the VM
            ;;
    esac
    echo  " src='data:$MIMETYPE;base64,`base64 $FILE`'"
    echo " />"
}

# end of imgLib.sh
