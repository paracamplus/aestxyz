#! /bin/sh
# Additional library for authors of exercises for FW4EX.
# This library should be sourced.

#=pod

# This library defines functions used in various patterns. It requires
# the C<basicLib.sh> and C<moreLib.sh> libraries. All these functions
# have names prefixed by C<fw4ex_>, they emit French sentences in
# UTF-8. Most of these functions are very simple so their source is
# given without much explanations.

#=head2 fw4ex_show_command_and_options_from_file

#=cut

fw4ex_show_command_and_options_from_file () {
    local COMMAND="$1"
    local OPTIONS="$2"
    cat <<EOF
<p>
Voici donc la commande que vous avez choisie:
<pre>
$( echo "$COMMAND $(cat $OPTIONS)" | fw4ex_transcode_carefully )
</pre></p>
EOF
}

#=head2 fw4ex_show_script

# Display a script but don't display files that are not recognized as
# text files. Also generate a special FW4EX tag in order to build an
# index of shown files.

#=cut

FW4EX_SHOW_SCRIPT_PREFIX_GOOD="Voici donc votre réponse:"
fw4ex_show_script () {
    local SCRIPT="$1"
    if [[ 0 -eq $( wc -c < "$SCRIPT" ) ]]
    then
        echo "<p><error>Votre fichier est vide!</error></p>"
    else
        case "$(file "$SCRIPT")" in
          *text*)
            fw4ex_generate_fw4ex_element "file:///$SCRIPT"
            cat <<EOF
<p>
$FW4EX_SHOW_SCRIPT_PREFIX_GOOD
<pre>
EOF
            fw4ex_transcode_carefully --l < "$SCRIPT"
            cat <<EOF
</pre></p>
EOF
            ;;
        *)
            cat <<EOF
<warning> Votre fichier 
<code>$( echo $SCRIPT | fw4ex_transcode_carefully )</code> 
ne semble pas être un texte, 
l'utilitaire <code>file</code> dit en effet que c'est un
<code>$( file "$SCRIPT" | fw4ex_transcode_carefully )</code>:
je ne tente donc pas de vous le montrer. </warning>
EOF
            ;;
        esac
    fi
}

#=head2 fw4ex_check_executability

#=cut

fw4ex_check_executability () {
    local SCRIPT="$1"
    if [[ -x "$SCRIPT" ]]
    then 
        return 0
    else
        cat <<EOF
<error> L'énoncé demandait un script exécutable ce que n'est pas votre
réponse. Je rectifie les droits au passage. </error>
EOF
        chmod a+x "$SCRIPT"
        return 1
    fi
}

#=head2 fw4ex_check_options_prefixed_by_command

#=cut

fw4ex_check_options_prefixed_by_command () {
    local COMMAND="$1"
    local OPTIONS="$2"
    local OPT=$( cat $OPTIONS )
    case "$OPT" in
        "$COMMAND "*)
            cat <<EOF
<warning> L'énoncé demandait les <strong>options</strong> à placer après la
commande <code>$COMMAND</code>, vous avez néanmoins fait précéder ces
options du nom de cette commande ce qui n'est pas conforme à la consigne!
Le reste sera probablement donc erroné. À l'avenir, lisez 
soigneusement les énoncés!
</warning>
EOF
            ;;
    esac
}

#=head2 fw4ex_show_data_file

# This function displays the content of a data file. It does not show
# the name of the data file only its content. It receives as first
# argument, the rank of the data file among the data files. 

#=cut

fw4ex_show_data_file () {
    local FLAG=
    if ${FW4EX_NUMBER_LINE:-false}
    then FLAG=--l
    fi
    local I="$1"
    local DATAFILE="$2"
    fw4ex_generate_fw4ex_element 'Essai' $I $( date -u +'%Y-%m-%dT%H:%M:%SZ' )
    if [[ -z "${DATAFORMATTER}" ]]
    then
        echo "<p> Voici le contenu du fichier $I à traiter: <pre>"
        fw4ex_transcode_carefully $FLAG < $DATAFILE
        echo "</pre></p>"
    else
        cat <<EOF
<p> Voici le contenu du fichier $I à traiter (que j'affiche avec 
<code>$DATAFORMATTER</code>): <pre>
EOF
        ${DATAFORMATTER:-cat} < $DATAFILE | fw4ex_transcode_carefully $FLAG
        echo "</pre></p>"
    fi
}

#=head2 fw4ex_show_directory_content

# This function displays the content of the current directory. It does
# not show the name of this directory only its content. It receives as
# first argument, the rank of the data file among the data files and,
# as second argument, the options to use to invoke C<ls>.

#=cut

fw4ex_show_directory_content () {
    local I="$1"
    local LS_FLAGS="${2:-gG}"
    fw4ex_generate_fw4ex_element Épreuve $I
    cat <<EOF
<p> Voici le contenu du répertoire $I en lequel opérer: <pre>
EOF
    ls $LS_FLAGS | fw4ex_transcode_carefully
    cat <<EOF
</pre></p>
EOF
}

#=head2 fw4ex_show_student_command

# This function echoes the command that will be run.

#=cut

fw4ex_show_student_command () {
    local COMMAND="$1"
    shift
    if $FW4EX_SHOW_COMMAND
    then
        cat <<EOF
<p> Je vais donc exécuter la commande suivante: <pre>
$( echo $COMMAND $@ | fw4ex_transcode_carefully )
</pre></p>
EOF
    fi
    if $DEBUG
    then 
        fw4ex_generate_xml_comment "$COMMAND" "$@"
    fi
}


#=head2 fw4ex_run_student_command

# This function takes the (student's) command to run as first
# argument. The student's command is confined, stdout and stderr are
# preserved in temporary files. By default, the C<PATH> is prepended
# with the HOME directory of the student though you may override this
# after setting the C<STUDENT_ADDITIONAL_PATH>.

#=cut

fw4ex_run_student_command () {
    local COMMAND="$1"
    shift
    chmod a+x "$COMMAND" 2>/dev/null
    ( 
        ( cd $TMPDIR/ && rm -f result.[st] result.n[st] ) 2>/dev/null
        PATH=${STUDENT_ADDITIONAL_PATH:-$HOME}:$PATH
        eval "fw4ex_confine $COMMAND ""$@" \
            2>$TMPDIR/err.s >$TMPDIR/result.s
        cp -p $TMPDIR/.lastExitCode $TMPDIR/.lastExitCode.s
        fw4ex_generate_xml_comment exitCode $( cat $TMPDIR/.lastExitCode.s )
        fw4ex_verbalize_error_code $TMPDIR/.lastExitCode.s
    )
}

#=head2 fw4ex_run_student_command_and_options_from_file 

# This function takes the (student's) command and options filename in
# order to build the whole command to run.

#=cut

fw4ex_run_student_command_and_options_from_file () {
    local COMMAND="$1"
    local OPTIONS="$2"
    fw4ex_run_student_command "$COMMAND" "$( cat $OPTIONS )"
}

#=head2 fw4ex_verbalize_error_code

# Analyse the content of the file holding the exit code of the last
# command ran by C<fw4ex_run_student_command>. if the exit code is 222
# or 228, then this is probably the confiner that ends the command, so
# we verbalise it in French.

#=cut

FW4EX_VERBALIZE_ALL_ERRONEOUS_CODE=false
fw4ex_verbalize_error_code () {
    local FW4EX_EXIT_FILE="${1:-$TMPDIR/.lastExitCode.s}"
    local code=$( cat $FW4EX_EXIT_FILE )
    if [ $( wc -l < $FW4EX_EXIT_FILE ) -ge 1 ]
    then
        if [ $code -eq 222 ]  # too much cpu, report to author
        then 
            echo "<error> Votre programme a été interrompu car 
il prenait trop de temps! </error>"
        elif [ $code -eq 228 ]  # too much output, report to author
        then 
            echo "<error> Votre programme a été interrompu car 
il produisait trop de caractères! </error>"
        elif [ $code -eq 211 ] # program not started
        then
            echo "<error> Je n'ai pas réussi à lancer votre programme:
bizarre! </error>"
        else
        # confiner internal error: ignore it!
            :
        fi
    elif $FW4EX_VERBALIZE_ALL_ERRONEOUS_CODE
    then if [ $code -ne 0 ]
         then echo "<warning> Le code de retour de votre programme est 
<code>$code</code> !? </warning>"
         fi
    fi
}

#=head2 fw4ex_show_student_raw_result

# Display the content of the stdout accumulated in the
# C<$TMPDIR/result.s> file by the C<fw4ex_run_student_command> script.

# Sometimes, the result file is so large that it is inconvenient to
# display it without some additional formating (a presentation with
# several columns or a graphical presentation may be more suited). You
# may specify the formatter (by default C<cat>) with the C<FORMATTER>
# variable.

#=cut

FW4EX_NUMBER_LINE=false

fw4ex_show_student_raw_result () {
    local FLAG=
    if ${FW4EX_NUMBER_LINE:-false}
    then FLAG=--l
    fi

    if [[ -z "${FORMATTER}" ]]
    then
        if [[ -s $TMPDIR/result.s ]]
        then ( 
                trap 'echo "</pre></p>"' 0
                echo "<p> Votre commande produit:<pre>"
                ${FORMATTER:-cat} < $TMPDIR/result.s | \
                    fw4ex_transcode_carefully $FLAG 
             )
        else
            echo "<p>Votre commande n'a rien émis sur son flux de sortie.</p>"
        fi
    else (
            trap 'echo "</pre></p>"' 0
            cat <<EOF
<p> Votre commande produit un résultat (que j'affiche avec 
<code>$FORMATTER</code>):<pre>
EOF
            ${FORMATTER:-cat} < $TMPDIR/result.s | \
                fw4ex_transcode_carefully $FLAG 
          )
    fi
    fw4ex_show_student_stderr
}

#=head2 fw4ex_show_student_stderr

# Display the content of the stderr if not empty. The stderr was
# accumulated in the C<$TMPDIR/err.s> file by the
# C<fw4ex_run_student_command> script.

#=cut

fw4ex_show_student_stderr () {
    if [[ -s $TMPDIR/err.s ]]
    then (
            
            trap 'echo "</pre></error>"' 0
            cat <<EOF
<error> Attention! Votre commande a aussi produit les anomalies suivantes 
sur son flux d'erreur: <pre>
EOF
            fw4ex_transcode_carefully < $TMPDIR/err.s
         )
    fi
}

# PB cf. com.paracamplus.li362.sh.4
fw4ex_penalize_student_if_non_empty_stderr () {
    local PENALTY="$1"
    if [[ -s $TMPDIR/err.s ]]
    then 
        cat <<EOF
<p> Comme votre commande produit des anomalies, je vous retire
EOF
        fw4ex_win "-$PENALTY"
        echo "points.</p>"
    fi
}

#=head2 fw4ex_run_teacher_command

# This command takes a command as first argument followed by
# additional arguments. It runs the command in a specialized C<PATH>
# that is, the value of C<TEACHER_ADDITIONAL_PATH> is prepended. The
# default value of C<TEACHER_ADDITIONAL_PATH> is
# C<FW4EX_EXERCISE_DIR>. 

# Similarly to C<fw4ex_run_student_command>, the result is stored into
# C<$TMPDIR/result.t> and the exit code is stored into
# C<$TMPDIR/.lastExitCode.t>. 

#=cut

fw4ex_run_teacher_command () {
    local COMMAND="$1"
    shift
    case "$COMMAND" in
        */*)
            if [ ! -x "$COMMAND" ]
            then
                echo "Je ne vois pas de fichier $COMMAND executable!" 1>&2
            fi
            ;;
        *)
            true
            ;;
    esac
    if $DEBUG
    then 
        fw4ex_generate_xml_comment "$COMMAND ""$@"
    fi
    (
        PATH=${TEACHER_ADDITIONAL_PATH:-$FW4EX_EXERCISE_DIR}:$PATH
        eval "fw4ex_confine $COMMAND ""$@" >$TMPDIR/result.t
        cp -p $TMPDIR/.lastExitCode $TMPDIR/.lastExitCode.t
        fw4ex_generate_xml_comment exitCode $( cat $TMPDIR/.lastExitCode )
    )
}

#=head2 fw4ex_run_teacher_command_and_options_from_file

#=cut

fw4ex_run_teacher_command_and_options_from_file () {
    local COMMAND="$1"
    local SOLUTION="$2"
    fw4ex_run_teacher_command "$COMMAND" "$( cat $SOLUTION )"
}

#=head2 fw4ex_show_teacher_raw_result

# Sometimes, the result file is so large that it is inconvenient to
# display it without some additional formating (a presentation with
# several columns or a graphical presentation may be more suited). You
# may specify the formatter (by default C<cat>) with the C<FORMATTER>
# variable.

#=cut

fw4ex_show_teacher_raw_result () {
    local FLAG=
    if ${FW4EX_NUMBER_LINE:-false}
    then FLAG=--l
    fi
    (
        trap 'echo "</pre>"' 0
        cat <<EOF
<p> Ma commande produit:</p><pre>
EOF
        ${FORMATTER:-cat} < $TMPDIR/result.t | \
            fw4ex_transcode_carefully $FLAG 
     )
}

#=head2 fw4ex_normalize_and_show_results

# This function normalizes the result files. If the C<NORMALIZER>
# variable is missing, then C<cat> (the identity function) is used
# otherwise the C<NORMALIZER> is the name of the filter to normalize
# the standard input into the standard output. The same filter
# normalizes the student's result and the author's result. 

# To normalize the results is often needed before comparing them. The
# normalization may sort, remove undesirable characters, etc.

# However, sometimes, the results files are so large that it is
# inconvenient to display them without some additional formating (a
# presentation with several columns or a graphical presentation may be
# more suited). You may specify the formatter (by default C<cat>) with
# the C<FORMATTER> variable.

# The C<COMPARISON_DISPOSITION> variable tells how to display the
# normalized results. If the lines of these files are short, then the
# C<landscape> mode where the results are displayed side by side may
# be preferred. If missing this variable defaults to C<vertical>.

#=cut

fw4ex_normalize_and_show_results () {
    if [ ! -s $TMPDIR/result.s ]
    then touch $TMPDIR/result.s
    fi
    ${NORMALIZER:-cat} < $TMPDIR/result.s > $TMPDIR/result.ns 2>$TMPDIR/normerr.txt
    if [ ! -s $TMPDIR/result.t ]
    then touch $TMPDIR/result.t
    fi
    ${NORMALIZER:-cat} < $TMPDIR/result.t > $TMPDIR/result.nt

    if [[ -z "${NORMALIZER}" ]]
    then
        return
    fi

    local FLAG=
    if ${FW4EX_NUMBER_LINE:-false}
    then FLAG=--l
    fi

    cat <<EOF
<p> Je normalise votre résultat et le mien afin de les comparer 
dans le respect de l'énoncé. </p>
EOF
    local MODE="${1:-${COMPARISON_DISPOSITION:-vertical}}"
    case "$MODE" in
        ################################
        landscape|horizontal|stacked)
            # stacked means tabs!
            cat <<EOF
<comparison><student><pre>
EOF
            ${FORMATTER:-cat} < $TMPDIR/result.ns | \
                fw4ex_transcode_carefully $FLAG
            echo "</pre>"
            if [[ -s $TMPDIR/normerr.txt ]]
            then
                cat <<EOF
<error> Attention! La normalisation de votre résultat a aussi produit 
les anomalies suivantes sur son flux d'erreur: <pre>
EOF
                fw4ex_transcode_carefully < $TMPDIR/normerr.txt
                cat <<EOF
</pre></error>
EOF
            fi
            cat <<EOF
</student><teacher><pre>
EOF
            ${FORMATTER:-cat} < $TMPDIR/result.nt | \
                fw4ex_transcode_carefully $FLAG 
            cat <<EOF
</pre></teacher></comparison>
EOF
            ;;
        ################################
        portrait|vertical|*)
            cat <<EOF
<p>Votre commande produit donc: <pre>
EOF
            ${FORMATTER:-cat} < $TMPDIR/result.ns | \
                fw4ex_transcode_carefully $FLAG
            echo "</pre></p>"
            if [[ -s $TMPDIR/normerr.txt ]]
            then
                cat <<EOF
<error> Attention! La normalisation de votre résultat a aussi produit 
les anomalies suivantes sur son flux d'erreur: <pre>
EOF
                fw4ex_transcode_carefully < $TMPDIR/normerr.txt
                cat <<EOF
</pre></error>
EOF
            fi
            cat <<EOF
<p> Tandis que ma commande produit: <pre>
EOF
            ${FORMATTER:-cat} < $TMPDIR/result.nt | \
                fw4ex_transcode_carefully $FLAG 
            cat <<EOF
</pre></p>
EOF
            ;;
    esac
}

#=head2 fw4ex_compare_results

# This is the generalized comparator. The C<COMPARISON> variable tells
# which kind of comparison to perform. Possible values for
# C<COMPARISON> are C<string>, C<line>, C<code> or C<int> (synonyms
# and plural forms are also possible). See the specialized comparators
# for further details.

#=cut

fw4ex_compare_results () {
    case "${COMPARISON}" in 
        char|character|characters|string|strings)
            fw4ex_compare_results_as_strings
            ;;
        line|lines)
            fw4ex_compare_results_as_lines
            ;;
        code|codes)
            fw4ex_compare_results_as_codes
            ;;
        int|integer|integers)
            fw4ex_compare_results_as_integers
            ;;
        *)
            echo "Cannot find such a comparison ($COMPARISON) ?" 1>&2
            $ABORT 101
            ;;
    esac
}

#=head2 fw4ex_compare_results_as_strings 

# Compare the content of two files (a student file and a teacher file)
# and return the Levenshthein distance.

#=cut

fw4ex_compare_results_as_strings () {
    local S_RESULT="$TMPDIR/result.ns"
    local T_RESULT="$TMPDIR/result.nt"
    if [[ ! -f $S_RESULT ]]
    then S_RESULT="$TMPDIR/result.s"
    fi
    if [[ ! -f $T_RESULT ]]
    then T_RESULT="$TMPDIR/result.t"
    fi
    cat <<EOF
<p> Je compare les deux résultats.
EOF
    local DISTANCE=$( fw4ex_compare_strings \
        "$(cat $S_RESULT)" \
        "$(cat $T_RESULT)" )
    fw4ex_verbalize_strings_comparison $DISTANCE
    echo "Vous gagnez "
    eval "fw4ex_win $WIN_FORMULA -- $DISTANCE"
    echo "point(s).</p>"
}

fw4ex_verbalize_strings_comparison () {
    local DISTANCE="$1"
    echo "$DISTANCE" > $TMPDIR/.distance
    if [[ "$DISTANCE" -eq 0 ]]
    then 
        cat <<EOF
Bravo! Je ne vois pas de différence.
EOF
    elif [[ "$DISTANCE" -eq 1 ]]
    then cat <<EOF
Je trouve qu'il faut insérer/modifier/supprimer $DISTANCE caractère
pour passer de l'un à l'autre.
EOF
    else cat <<EOF
Je trouve qu'il faut insérer/modifier/supprimer $DISTANCE caractères
pour passer de l'un à l'autre. 
EOF
    fi
}

#=head2 fw4ex_compare_results_as_lines

#=cut

fw4ex_compare_results_as_lines () {
    local S_RESULT="$TMPDIR/result.ns"
    local T_RESULT="$TMPDIR/result.nt"
    if [[ ! -f $S_RESULT ]]
    then S_RESULT="$TMPDIR/result.s"
    fi
    if [[ ! -f $T_RESULT ]]
    then T_RESULT="$TMPDIR/result.t"
    fi
    cat <<EOF
<p> Je compare les deux résultats.
EOF
    local DISTANCE=$( fw4ex_compare_lines "$S_RESULT" "$T_RESULT" )
    fw4ex_verbalize_lines_comparison $DISTANCE
    echo "Vous gagnez "
    eval "fw4ex_win $WIN_FORMULA -- $DISTANCE"
    echo "point(s).</p>"
}

fw4ex_verbalize_lines_comparison () {
    local DISTANCE="$1"
    echo "$DISTANCE" > $TMPDIR/.distance
    if [[ "$DISTANCE" -eq 0 ]]
    then 
        cat <<EOF
Bravo! Je ne vois aucune différence.
EOF
    elif [[ "$DISTANCE" -eq 1 ]]
    then cat <<EOF
Je trouve qu'il faut insérer/modifier/supprimer $DISTANCE ligne
pour passer de l'un à l'autre.
EOF
    else cat <<EOF
Je trouve qu'il faut insérer/modifier/supprimer $DISTANCE lignes
pour passer de l'un à l'autre.
EOF
    fi    
}

#=head2 fw4ex_compare_results_as_codes

# Compare two exit values. If the C<SUCCESS_FAILURE> variable is true
# then only success (exit codes both 0) or failure (exit codes both
# different from 0) is checked.

#=cut

fw4ex_compare_results_as_codes () {
    local SUCCESS_FAILURE=${SUCCESS_FAILURE:-false}
    local S_RESULT=$( cat $TMPDIR/.lastExitCode.s )
    local T_RESULT=$( cat $TMPDIR/.lastExitCode.t )
    cat <<EOF
<p> Je compare les deux codes de retour: 
votre code de retour est $S_RESULT,
mon code de retour est $T_RESULT.
EOF
    if $SUCCESS_FAILURE
    then
        if [[ $S_RESULT -ne 0 ]]
        then 
            echo "Votre commande s'est donc mal terminée."
            S_RESULT=1
        fi
        if [[ $T_RESULT -ne 0 ]]
        then 
            echo "Ma commande s'est donc mal terminée."
            T_RESULT=1
        fi
    fi
    local DISTANCE=$( fw4ex_compare_integers $S_RESULT $T_RESULT )
    echo "Vous gagnez "
    eval "fw4ex_win $WIN_FORMULA -- $DISTANCE"
    echo "point(s).</p>"
}

#=head2 fw4ex_compare_results_as_integers

# This function compares the two normalized results files
# C<$TMPDIR/result.ns> (normalized student's result) and
# C<$TMPDIR/result.nt> (normalized teacher's result). These two files
# (or the non-normalized files C<$TMPDIR/result.s> and
# C<$TMPDIR/result.t> if they do not exist) are then filtered in order
# to remove any non numerical characters. The two resulting numbers
# are then compared and their distance (the absolute value of their
# difference) is computed and given to the C<WIN_FORMULA>. 

#=cut

fw4ex_compare_results_as_integers () {
    local S_RESULT="$TMPDIR/result.ns"
    local T_RESULT="$TMPDIR/result.nt"
    if [[ ! -f $S_RESULT ]]
    then S_RESULT="$TMPDIR/result.s"
    fi
    if [[ ! -f $T_RESULT ]]
    then T_RESULT="$TMPDIR/result.t"
    fi
    if $DEBUG
    then
        fw4ex_generate_xml_comment "S_RESULT=$S_RESULT"
        fw4ex_generate_xml_comment "T_RESULT=$T_RESULT"
    fi
    S_RESULT=$( tr -cd 0-9 < $S_RESULT | sed -re 's/^0*(.+)$/\1/' )
    T_RESULT=$( tr -cd 0-9 < $T_RESULT | sed -re 's/^0*(.+)$/\1/' )
    cat <<EOF
<p> Je compare les deux valeurs:
la vôtre est $S_RESULT,
la mienne est $T_RESULT.
EOF
    local DISTANCE=$( fw4ex_compare_integers $S_RESULT $T_RESULT )
    echo "Vous gagnez "
    eval "fw4ex_win $WIN_FORMULA -- $DISTANCE"
    echo "point(s).</p>"
}


# {{{ Hooks

fw4ex_after_student_run_hook () {
    :
}

fw4ex_after_teacher_run_hook () {
    :
}

# }}}
  
# Local Variables: ##
# coding:utf-8 ##
# End: ##
# end of comparisonLib.sh
