#! /bin/bash
# Additional library for authors of exercises for FW4EX.
# This library should be sourced.

#=pod

# This pattern corresponds to an exercise that asks for a set of
# options (a string) to tailor a command so it behaves as specified by
# the stem. The command will be run in various directories.

# This pattern gauges the student's answer by comparison to the
# author's solution. The command receives data files on its stdin, the
# result is in the stdout. To sum up and using the variables
# documented below, this pattern may be roughly characterized as:

#         cd $datadir/ && $COMMAND $( cat $OPTIONS )

# This pattern emits a grading report in French (encoded as UTF-8).
# Here is a short example:

#  COMMAND=tr
#  NORMALIZER=removeTrailingBlanks
#  COMPARISON=char
#  TOTAL_WIN=10
#  WIN_FORMULA='triangular 0 0 5 $TOTAL_WIN/$DATA_NUMBER'

#  removeTrailingBlanks () {
#     sed -e 's/ *$//'
#  }

#  source $FW4EX_LIB_DIR/Patterns/Moulin.sh

# Here are the parameters to configure this pattern.

#=head2 COMMAND

# This variable defines the program to run. The final command will be
# made of the program followed by the options proposed by the student.

#=head2 OPTIONS

# This variable specifies the name of the file that contains the
# string of options (a single line). Pay attention, the variable does
# not hold the options but the filename where are stored the
# options. By default, this file is named C<options>.

#=cut

OPTIONS=${OPTIONS:-options}

#=head2 COMMAND_STDIN

# This variable specifies the standard input to be given to
# C<COMMAND>. By default, this is C</dev/null>.

#=cut

COMMAND_STDIN=${COMMAND_STDIN:-/dev/null}

#=head2 SOLUTION

# This variable specifies the name of the file that contains a correct
# solution that is a string of options achieving the desired behavior.
# By default, this pattern assumes that a C<perfect> pseudo-job exists
# that contains the appropriate file named by the previous variable
# C<OPTIONS>.

#=cut

SOLUTION=${SOLUTION:-$FW4EX_EXERCISE_DIR/pseudos/perfect/$OPTIONS}

#=head2 CHECK_OPTIONS

# A common mistake is to prepend options with the name of the command.
# The stem should ask for options not for the whole command. See
# pattern \ref{pattern:Digne} for that. By default, this variable is
# C<true> and signals the mistake. Set this variable to C<false> if
# this is not desired. 

# Whether the mistake is signalled or not, the grading process continues.

#=cut

CHECK_OPTIONS=${CHECK_OPTIONS:-true}

#=head2 DATA_DIR

# This variable is the name of the directory that contains the test
# directories. By default, test directories are located in the
# C<tests/> directory of the tar gzipped exercise. This directory
# should be defined with an absolute pathname.

#=cut

DATA_DIR=${DATA_DIR:-$FW4EX_EXERCISE_DIR/tests}

#=head2 DATA_SUFFIX

# This variable tells the suffix the test files have. By default, the
# suffix is C<d>. Any directory with that suffix in the C<DATA_DIR>
# directory is a test directory. Test directories are used in
# alphabetic order.

# The number of tests is therefore the number of directories in
# C<$DATA_DIR/*.$DATA_SUFFIX/>. This number will be computed by the
# pattern and set as the value of the C<DATA_NUMBER> variable.

#=cut

DATA_SUFFIX=${DATA_SUFFIX:-d}

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

#=head2 FW4EX_SHOW_COMMAND

# This boolean variable controls whether to display the command to run.

#=cut

FW4EX_SHOW_COMMAND=${FW4EX_SHOW_COMMAND:-true}

#=head2 Script

# The script is sufficiently short to be shown. It uses the
# C<basicLib.sh>, C<moreLib.sh> and C<comparisonLib.sh> libraries. The
# presence of the OPTIONS file is already checked.

#=cut

 # Show the command that will be run to the student:

fw4ex_show_command_and_options_from_file "$COMMAND" "$OPTIONS"

 # Check if students prefix their options by the name of the command:

if $CHECK_OPTIONS
then
    fw4ex_check_options_prefixed_by_command "$COMMAND" "$OPTIONS"
fi

 # For every data file, run student's and author's program and compare:

DATA_NUMBER=$( ls -d1 $DATA_DIR/*.${DATA_SUFFIX}/ | wc -l )
if [[ $DATA_NUMBER -eq 0 ]] ; then exit ; fi
cat <<EOF
<p>
Je vais comparer votre solution et la mienne sur $DATA_NUMBER 
répertoires de données.
</p>
EOF

I=0
 # Iterate on every data file
for datadir in $DATA_DIR/*.${DATA_SUFFIX}/
do 
    I=$(( $I+1 ))
    ( 
        trap 'echo "</section>"' 0
        OPTIONS=$(pwd)/$OPTIONS
        cd $datadir
        # Describe the test ie show the content of the data directory:
        echo "<section rank='$I'>"
        fw4ex_show_directory_content $I "$datadir"

        # Show student's command:
        fw4ex_show_student_command "$COMMAND" "$( cat $OPTIONS )" \
            " < $COMMAND_STDIN"
        # Run student's command:
        fw4ex_run_student_command_and_options_from_file \
            "$COMMAND" "$OPTIONS" < $COMMAND_STDIN
        # and show raw result of this command:
        fw4ex_show_student_raw_result
        # Possible hook for authors:
        fw4ex_after_student_run_hook $I "$datadir"

        # Run author's command. If this command is erroneous, errors
        # will be emitted on stderr and sent to the author.
        fw4ex_run_teacher_command_and_options_from_file \
            "$COMMAND" "$SOLUTION" < $COMMAND_STDIN
        fw4ex_show_teacher_raw_result
        fw4ex_after_teacher_run_hook $I "$datadir"
        
        # Normalize then show raw results:
        if [[ -n "$NORMALIZER" ]]
        then
            fw4ex_normalize_and_show_results
        fi

        # Compare normalized results and determine the win:
        fw4ex_compare_results
    )
done

# Local Variables: ##
# coding:utf-8 ##
# End: ##
# end of Moulin.sh
