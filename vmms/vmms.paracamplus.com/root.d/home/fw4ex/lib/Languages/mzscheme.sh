#! /bin/bash
# -*- coding: utf-8 -*-
# Additional library for authors of exercises for FW4EX.
# This library should be sourced.

#=pod

# This pattern corresponds to an exercise that asks for a Scheme file. 

# This pattern gauges the student's answer by comparison to the
# author's solution. 

# This pattern emits a grading report in French (encoded as UTF-8).
# Here is a short example:

#  NORMALIZER=removeTrailingBlanks
#  COMPARISON=line
#  TOTAL_WIN=10
#  WIN_FORMULA='triangular 0 0 5 $TOTAL_WIN/$DATA_NUMBER'

#  removeTrailingBlanks () {
#     sed -e 's/ *$//'
#  }

#  source $FW4EX_LIB_DIR/Languages/mzscheme.sh

# Here are the parameters to configure this pattern.

#=head2 COMMAND

# This variable specifies the name of the Scheme evaluator. By
# default, this file is named C<mzscheme>. This command will receive
# the name of the data file as an argument surrounded with LEFT_FLAGS
# and RIGHT_FLAGS.

#=cut

COMMAND=${COMMAND:-mzscheme}

#=head2 INPUT

# This variable specifies the name of the file containing the Scheme
# functions. It will be run by the Scheme evaluator mentioned in
# C<COMMAND>. This variable has no default.

INPUT=${INPUT:-NoSchemeFile.scm}

#=head2 LEFT_FLAGS

# This variable contains additional arguments to be given to
# C<COMMAND> before the name of the data file. By default, this
# variable is empty.

#=cut

LEFT_FLAGS=${LEFT_FLAGS:-}

#=head2 RIGHT_FLAGS

# This variable contains additional arguments to be given to
# C<COMMAND> after the name of the data file. By default, this
# variable is empty.

#=cut

RIGHT_FLAGS=${RIGHT_FLAGS:-}

#=head2 COMMAND_STDIN

# This variable specifies the standard input to be given to
# C<COMMAND>. By default, this is C</dev/null>.

#=cut

COMMAND_STDIN=${COMMAND_STDIN:-/dev/null}

#=head2 SOLUTION

# This variable specifies the name of the file that contains a correct
# solution. By default, this pattern assumes that a C<perfect>
# pseudo-job exists that contains the appropriate file named by the
# previous variable C<COMMAND>.

#=cut

SOLUTION=${SOLUTION:-$FW4EX_EXERCISE_DIR/pseudos/perfect/$INPUT}

#=head2 DATA_DIR

# This variable is the name of the directory that contains the test
# files. By default, test files are located in the C<tests/> directory
# of the tar gzipped exercise. This directory should be defined with
# an absolute pathname.

#=cut

DATA_DIR=${DATA_DIR:-$FW4EX_EXERCISE_DIR/tests}

#=head2 DATA_SUFFIX

# This variable tells the suffix the test files have. By default, the
# suffix is C<data>. Any file with that suffix in the C<DATA_DIR>
# directory is a test file. Test files are used in alphabetic order.

# The number of tests is therefore the number of files in
# C<$DATA_DIR/*.$DATA_SUFFIX>. This number will be computed by the
# pattern and set as the value of the C<DATA_NUMBER> variable.

#=cut

DATA_SUFFIX=${DATA_SUFFIX:-scm}

#=head2 NORMALIZER

# This variable contains the name of the command (program + options or
# internal bash function as shown in the synopsis above) that
# normalizes the output of the programs to compare. You are not
# required to define this variable if you don't need normalization.

#=head2 COMPARISON

# This variable contains a word that defines the kind of comparison.

#=over 

#=item

# The C<char> comparison computes the Levenshtein distance between the
# student's answer and the author's answer. The Levenshtein distance
# should not be used to compare too long strings.

#=item

# The C<line> comparison uses the C<diff> utility to count the number
# of dissimilar lines.

#=item

# The C<code> comparison compares the exit codes of the student's and
# author's commands.

#=item 

# The C<int> comparison compares the stdout of the student's and
# author's commands. These stdout are assumed to be integers.

#=back

# The C<COMPARISON> variable is there to ease switching from one
# comparison method to another. If you're sure you may remove that
# intermediate and patch the script below.

#=cut

COMPARISON=${COMPARISON:-char}

# This variable allows to emit some debug information. Attention, a
# clever student may use that information to get some understanding of
# the tests that are run or even on the solution itself.

DEBUG=${DEBUG:-false}

#=head2 TOTAL_WIN

# This variable defines the maximal mark that may be won. Given the
# nature of the pattern, any test case allows the student to win
# C<TOTAL_WIN/DATA_NUMBER> (rounded to two decimals only). To avoid
# embarrassing rounding, avoid a C<TOTAL_WIN> of 1 with only 3 tests.
# The total mark will amount to 0.99 instead of 1.

#=head2 WIN_FORMULA

# This variable defines how to compute the number of points a student
# wins for one test file. The comparison (determined by COMPARISON)
# computes a distance: 0 is perfection (student's and author's
# normalized answers are the same). The C<WIN_FORMULA> variable
# defines how to convert the distance into a mark. It defines the
# first arguments of a call to C<win.pl>. See documentation of this
# utility for more details.

#=head2 FW4EX_SHOW_SCRIPT

# This boolean variable controls whether the student's scheme file
# will be displayed or not. By default, the script is displayed.

#=cut

FW4EX_SHOW_SCRIPT=${FW4EX_SHOW_SCRIPT:-true}

#=head2 FW4EX_SHOW_COMMAND

# This boolean variable controls whether to display the command to run.

#=cut

FW4EX_SHOW_COMMAND=${FW4EX_SHOW_COMMAND:-true}

#=head2 NORMALIZER

# This function normalizes the output of mzscheme: it removes the
# banner and the prompts

#=cut

normalize_mzscheme() {
    sed -e 1d -e 's/^> //' 2>$TMPDIR/normerr.txt
}

NORMALIZER=normalize_mzscheme

#=head2 Script

# The script is sufficiently short to be shown. It uses the
# C<basicLib.sh>, C<moreLib.sh> and C<comparisonLib.sh> libraries. The
# presence of the COMMAND file is already checked.

#=cut

 # Show the Scheme file that will be run to the student:

if $FW4EX_SHOW_SCRIPT
then
    fw4ex_show_script "$INPUT"
fi

 # For every data file, run student's and author's program and compare:

DATA_NUMBER=$( ls -1 $DATA_DIR/*.${DATA_SUFFIX} | wc -l )
if [[ $DATA_NUMBER -eq 0 ]] ; then exit ; fi
cat <<EOF
<p>
Je vais comparer votre solution et la mienne sur $DATA_NUMBER essais.
</p>
EOF

I=0
 # Iterate on every data file
for data in $DATA_DIR/*.${DATA_SUFFIX}
do 
    I=$(( $I+1 ))
    (
        trap 'echo "</section>"' 0
        # Describe the test ie show the content of the data file:
        echo "<section rank='$I'>"
        fw4ex_show_data_file $I "$data"

        # Show student's command:
        fw4ex_show_student_command "$COMMAND" \
             $LEFT_FLAGS "$INPUT" $RIGHT_FLAGS '<' "$data"
        # Run student's command:
        fw4ex_run_student_command "$COMMAND" \
            $LEFT_FLAGS "$INPUT" $RIGHT_FLAGS < "$data"
        # and show raw result of this command:
        fw4ex_show_student_raw_result
        # Possible hook for authors:
        fw4ex_after_student_run_hook $I "$data"
        
        # Run author's command. If this command is erroneous, errors
        # will be emitted on stderr and sent to the author.
        fw4ex_run_teacher_command "$COMMAND" \
            $LEFT_FLAGS "$SOLUTION" $RIGHT_FLAGS < "$data"
        fw4ex_show_teacher_raw_result
        fw4ex_after_teacher_run_hook $I "$data"

        # Normalize then show raw results:
        if [[ -n "$NORMALIZER" ]]
        then
            fw4ex_normalize_and_show_results
        fi
        
        # Compare normalized results and determine the win:
        fw4ex_compare_results
    )
done

# end of mzscheme.sh
