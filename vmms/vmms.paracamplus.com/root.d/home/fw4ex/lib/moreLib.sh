#! /bin/sh
# Additional library for authors of exercises for FW4EX.
# This library should be sourced.

#=pod

# This library defines additional functions that may be useful for
# authors. This file defines some internal functions that are not
# documented.

#=head2 fw4ex_ensure_final_newline

# This function appends a final newline to a file if this new newline
# is missing. This is sometimes useful to sanitize student's data
# files.

#=cut

fw4ex_ensure_final_newline () {
    local FILE="$1"
    local CHAR=$( tail --bytes=1 < "$FILE" | od -w1 -c -An )
    case "$CHAR" in
        *'\n'*)
            return 0
            ;;
        *)
            echo >>"$FILE"
            return 1
            ;;
    esac
}

#=head2 fw4ex_check_existence

# This function checks whether a file exists (ie whether the student
# submits this file), is readable and not empty. Aborts (with the
# content of the C<ABORT> variable) the current script if the file
# does not exist. Another setting for C<ABORT> is C<return>.

# Verbalizes the check while doing it.

#=cut

fw4ex_check_existence() {
    local ABORT=${ABORT:-exit}
    local FILE="$1"

    if [[ ! -f "$FILE" ]]
    then 
        cat <<EOF
<error>Je ne trouve pas de fichier nommé <code>$FILE</code>! </error>
EOF
        $ABORT 51
    fi

    if [[ ! -r "$FILE" ]]
    then 
        chmod a+r "$FILE"
    fi

    if [[ ! -s "$FILE" ]]
    then
        cat <<EOF
<error>Votre fichier nommé <code>$FILE</code> est vide! </error>
EOF
        $ABORT 52
    fi
}

#=head2 fw4ex_show_directory

# List the given directory (by default, the current directory).

#=cut

fw4ex_show_directory () {
    local DIR="$1"
    if [[ -n "$DIR" ]]
    then
        echo "<p> Voici le contenu du répertoire <code>$DIR</code>: <pre>"
        (cd $DIR/ && ls -RgG ) | fw4ex_transcode_carefully
    else
        echo "<p> Voici le contenu de votre répertoire: <pre>"
        ls -RgG | fw4ex_transcode_carefully
    fi
    echo "</pre></p>"
}

#=head2 fw4ex_compare_strings

# Compare two strings using Levenshthein distance that is, the number
# of insertions/deletion/substitution needed to change the first
# (student's) string into the second (author's) one. Return that
# number in order to compute a partial mark. Don't give too long
# strings or the computation may take time.

#=cut

fw4ex_compare_strings() {
    local STUDENT="$1"
    local TEACHER="$2"
    if false
    then
        # Il y a un probleme la-dessous (test 103c ???)
        perl -e "use Text::Levenshtein qw(distance);
                 print distance('$STUDENT', '$TEACHER'); "
    else
        # Pure perl             FUTURE a confiner a 5 secondes max ???
        $FW4EX_LIB_DIR/levenshtein.pl "$STUDENT" "$TEACHER"
    fi
}

#=head2 fw4ex_compare_lines

# Compare two files counting the number of insertions, deletion or
# substitution needed to change the first (student's) file into the
# second (author's) one. Return that number in order to compute a
# partial mark. Don't give too much lines or the computation may take
# time.

# Additionnally, you may add other options to C<diff> in the third
# argument. If the third argument is missing, it defaults to the value
# of the global variable C<DIFF_AUTHOR_FLAGS>.

#=cut

fw4ex_compare_lines() {
    local STUDENT="$1"
    local TEACHER="$2"
    local DIFF_AUTHOR_FLAGS="${3:-$DIFF_AUTHOR_FLAGS}"
    local DIFF_FLAGS='--unchanged-line-format= --old-line-format=O --new-line-format=N'
    local RESULT=$( diff $DIFF_AUTHOR_FLAGS $DIFF_FLAGS $STUDENT $TEACHER )
    #echo "<!-- $RESULT -->"
    echo ${#RESULT}
}

#=head2 fw4ex_compare_integers

# Compare two integers (for example two exit values). Return the
# distance between them (probably not a very meaningful distance for
# exit values) in order to compute the partial mark.

#=cut

fw4ex_compare_integers() {
    local STUDENT="$1"
    local TEACHER="$2"
    echo $(( $TEACHER - $STUDENT )) | sed -re 's/-//'
}

# {{{ Expectations checking runtime library

#=pod

# The <expectations> element from the C<fw4ex.xml> file automatizes
# the verification that the expected files are indeed present. The
# generated code uses the following four functions. All these
# functions only emit a text, they should not use 'exit'! An exit will
# automatically be performed after reporting a miss.

#=head2 fw4ex_report_present_file

# Generate a FW4EX comment telling if a file is present otherwise
# generate nothing.

#=cut

fw4ex_report_present_file() {
    local FILE="$1"
    fw4ex_generate_fw4ex_element $FILE is present
}

#=head2 fw4ex_report_missing_file

# Notify the user that an expected file is missing. Returns true only
# if the file is really missing.

#=cut

fw4ex_report_missing_file() {
    local FILE="$1"
    if [[ -f $FILE ]]
    then
        false
    else
        cat <<EOF
<error>Je ne trouve pas de fichier nommé <code>$FILE</code>! </error>
EOF
        true
    fi
}

#=head2 fw4ex_report_present_directory

# Generate a FW4EX comment telling if a directory is present otherwise
# generate nothing.

#=cut

fw4ex_report_present_directory() {
    local DIR="$1"
    fw4ex_generate_fw4ex_element $DIR is present
}

#=head2 fw4ex_report_missing_directory

# Notify the user that an expected directory is missing. Returns true
# only if this directory is really missing.

#=cut

fw4ex_report_missing_directory() {
    local DIR="$1"
    if [[ -f $DIR ]]
    then
        false
    else 
        cat <<EOF
<error>Je ne trouve pas de répertoire nommé <code>$DIR</code>! </error>
EOF
        true
    fi
}

# }}}
# Local Variables: ##
# coding:utf-8 ##
# End: ##
# end of moreLib.sh
