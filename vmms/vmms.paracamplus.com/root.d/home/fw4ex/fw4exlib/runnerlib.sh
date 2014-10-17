#! /bin/bash
# Bash libraries for the marker. This is the runtime library for xml2sh.
# All functions are prefixed with fw4ex_ not to clash with author's functions.

# This function analyses the exit code of the last confined command.
# It returns an exit code of 0 if the evaluation should continue or 1
# if the evaluation should be aborted. Additionally, in case of
# errors, it sends the errors to the right person.

fw4ex_analyse_exit_code() {
    local FW4EX_EXIT_FILE=$1
    local FW4EX_LOG_FILE=$2

    local code=$( cat $FW4EX_EXIT_FILE )
    if [ $( wc -l < $FW4EX_EXIT_FILE ) -ge 1 ]
    then # confiner error
        if [ $code -eq 222 ]  # too much cpu, report to author
        then {
                echo
                echo "<PROBLEM message='Your script consumes too much CPU!' />"
                echo
            } 1>&4

        elif [ $code -eq 228 ]  # too much output, report to author
        then {
                echo
                echo "<PROBLEM message='Your script produces too much output!' />"
                echo
            } 1>&4

        else { # confiner internal error, report to FW4EX maintaineer
                echo 
                echo "Problem confiner, error $code, log is: " 
                cat $FW4EX_LOG_FILE
                echo 
                echo 
            } 1>&2

        fi

    elif [ $code -eq 0 ]
    then # author's script ends normally
        return 0 
        
    else { # confinee error, report to author
            echo
            echo "<PROBLEM message='Script ends badly!' exit='$code' />"
            echo
        } 1>&4
    fi
    return 1
}

#

fw4ex_react_to_exit_code () {
    local FW4EX_EXIT_FILE=$1
    local FW4EX_LOG_FILE=$2
    local FW4EX_MODE="$3"
    fw4ex_analyse_exit_code $FW4EX_EXIT_FILE $FW4EX_LOG_FILE
    local CODE=$?
    if [[ $CODE -ne 0 ]]
    then case "$FW4EX_MODE" in
            'abort exercise')
                exit $CODE
                ;;
            'abort question')
                if [ -n "$FW4EX_QUESTION_NAME" ]
                then
                    # We are within a question, abort the current
                    # question then continue:
                    exit 0
                fi
                # This is a script not within a question, 'abort
                # question' is therefore non-sense! We just continue:
                ;;
            *)
                ;;
        esac
    fi
    # By default, if CODE = 0, we continue!
}

# transcode weird characters

fw4ex_transcode_carefully () {
    #sed -e 's/&/\&amp;/g' -e 's/</\&lt;/g' -e 's/>/\&gt;/g' 
    #$FW4EX_LIB_DIR/transcodeCarefully.pl
    expand | $FW4EX_BIN_DIR/transcode
}

# Generate a comment paying attention not to generate -- within the
# comment.

fw4ex_generate_xml_comment () {
    echo "<!--" $( echo "$@" | sed -r 's/-{2,}/-/g' | \
        fw4ex_transcode_carefully ) "-->"
}

# The <expectations> element automatizes the verification that the
# expected files are indeed present. The generated code uses the
# following four functions. All these functions only emit a text, they
# should not use 'exit'! An exit will automatically performed after
# reporting a miss.

# These functions differ from the fw4ex_analyse_exit_code since they
# have to report the problem to the student, not to the author nor to
# fw4ex maintaineer.

# NOTE: For now, they cannot be redefined since moreLib.sh (or
# oneLinerLib.sh) is not in scope while these checks are performed. 

fw4ex_report_present_file() {
    local FILE="$1"
    fw4ex_generate_xml_comment checked presence of $FILE 1>&3
}

fw4ex_report_missing_file() {
    local FILE="$1"
    cat 1>&3 <<EOF
<error>Je ne trouve pas de fichier nommé <code>$FILE</code>! </error>
EOF
}

fw4ex_report_present_directory() {
    local DIR="$1"
    fw4ex_generate_xml_comment checked presence of $DIR/ 1>&3
}

fw4ex_report_missing_directory() {
    local DIR="$1"
    cat 1>&3 <<EOF
<error>Je ne trouve pas de répertoire nommé <code>$DIR</code>! </error>
EOF
}

# Local Variables: ##
# coding:utf-8 ##
# End: ##
# end of runnerlib
