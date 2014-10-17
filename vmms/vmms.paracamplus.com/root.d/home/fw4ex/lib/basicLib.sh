#! /bin/bash
# Basic library for authors of exercises for FW4EX.
# This library should be sourced or emulated by authors'scripts.

#=pod

# This is the most basic library for authors. It defines a number of
# useful functions. The name of these functions is prefixed by
# C<fw4ex_>.

#=head2 fw4ex_transcode_carefully

# This is a filter to transcode weird characters into XML and UTF-8
# acceptable characters. Remember that every string (especially the
# strings coming from the student) going to appear in the grading
# report must pass through this filter so the generated XML is valid.

# Several options are possible: C<-l> numbers the lines.
# C<--g=N> limits the output to N characters: if the
# output overflows, a series of three characters is emitted.
# C<--b=N> limits the number of non-UTF8 bytes (the error
# code is 1). C<--s=N> cuts lines every N characters.

# The C<FW4EX_TRANSCODE_CAREFULLY_FLAGS> variable may be set to add
# permanently options to C<fw4ex_transcode_carefully>.

#=cut

fw4ex_transcode_carefully () {
    expand | $FW4EX_BIN_DIR/transcode $FW4EX_TRANSCODE_CAREFULLY_FLAGS "$@"
}

#=pod

# For instance, if you want to show to the student the command he
# submitted, use the following snippet:

#      echo $OPTIONS | fw4ex_transcode_carefully

#=head2 fw4ex_win

# This function emits a partial mark. These partial marks will be
# summed to form the final mark. A mark is a unique argument, a
# string, that may contain an arithmetic expression. Only two decimals
# will be retained for the partial mark to emit.

#=cut

fw4ex_win() {
    local POINT=$( $FW4EX_LIB_DIR/win.pl "$@" )
    fw4ex_generate_fw4ex_element formula: "$@"
    cat <<EOF
<mark key='$FW4EX_JOB_ID' value='$POINT'>$POINT</mark>
EOF
}

#=pod

# Here are some examples of wins:

#          fw4ex_win 1               # to win 1
#          fw4ex_win 1/3             # to win 0.33
#          fw4ex_win 3-\(5.6\*0.5\)  # to win 0.2
#          fw4ex_win "3 - (5.6*0.5)" # to win 0.2

#=head2 fw4ex_confine

# The C<fw4ex_confine> function allows an author to run some student's
# code in a confined mode so the student's code cannot exceed some
# limits (duration, output size (stdout or stderr)). Normally, an
# author should never run student's code out of a confined mode!

# Pay attention, that the author's scripts are themselves confined by
# the FW4EX platform so an author may only devote resources to
# student's scripts within his own limits.

# Normally, the maxcpu, maxout and maxerr limitations are already set
# for the author's script. If you want to set more precise limits (or
# hide additional environement variables) to run the student's script,
# use the C<FW4EX_STUDENT_LIMITS> variable, for instance:

#        FW4EX_STUDENT_LIMITS='--maxout=5k --cpu=1' 

# The exit code of the confined script will be stored in the
# TMPDIR/.lastExitCode file (initially filled with 211). The code 222
# is returned if the confined program was killed because it exceeds
# its specified duration. The code 228 if the confined program was
# killed because it exceeds the number of characters to be output on
# its stdout or stderr streams. Otherwise the the exit value of the
# confined process if it terminates naturally. See the C<confine>
# utility for more details.

# Please consider using C<fw4ex_run_student_command> or
# C<fw4ex_run_teacher_command> instead from the C<comparisonLib.sh>
# library.

# FUTURE DEBUG  retirer -v si present

#=cut

fw4ex_confine() {
    #fw4ex_generate_xml_comment "FW4EX_STUDENT_LIMITS=$FW4EX_STUDENT_LIMITS"
    echo -n 211 > $TMPDIR/.lastExitCode
    $FW4EX_BIN_DIR/confine \
        --exit-file $TMPDIR/.lastExitCode \
        $FW4EX_STUDENT_LIMITS \
        --fw4ex-hide \
        -- "$@"
}

#=head2 fw4ex_generate_xml_comment

# The C<fw4ex_generate_xml_comment> function is a deprecated internal
# technical function used to insert additional information within
# grading report not immediately seeable by students. Use it only for
# debug as it may leak useful information towards students.

# The C<fw4ex_generate_xml_comment> function generates a comment
# paying attention not to generate a sequence of two dashes (C<-->)
# within the comment.

#=cut

fw4ex_generate_xml_comment () {
    echo "<!--" $( echo "$@" | sed -r 's/-{2,}/-/g' | \
        fw4ex_transcode_carefully ) "-->"
}

#=head2 fw4ex_generate_fw4ex_element

# This is an internal technical function that emits an C<FW4EX>
# element. These elements are used to insert additional information
# within grading report and to resynchronize XML generation in case of
# generation problems.

#=cut

fw4ex_generate_fw4ex_element () {
    echo "<FW4EX what='" $( echo "$@" | fw4ex_transcode_carefully ) "'/>"
}

# Local Variables: ##
# coding:utf-8 ##
# End: ##
# end of basicLib.sh
