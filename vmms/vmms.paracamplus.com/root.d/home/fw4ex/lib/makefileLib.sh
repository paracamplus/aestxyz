#! /bin/bash
# Library for authors of exercises for FW4EX to ease testing Makefiles.
# This library should be sourced.

MAKE=make

#=pod

# This library is used when dealing with make or gcc. It defines a
# number of useful functions. The name of these functions is prefixed
# by C<fw4ex_>.

#=head2 fw4ex_is_relocatable

# This predicate takes a filename as argument and checks whether it is
# a relocatable file (that is a C<.o> file) or not. The check is made
# with the C<file> utility (pay attention to the current LANG value).

#=cut

fw4ex_is_relocatable () {
    local FILE="$1"
    case "$( file $FILE )" in
        *relocatable*)
            true
            ;;
        *)
            false
            ;;
    esac
}

#=head2 fw4ex_is_library 

# This predicate takes a filename as argument and checks whether it is
# a library file (that is, a C<.a> file). The check is made with the
# C<file> utility (pay attention to the current LANG value).

#=cut

fw4ex_is_library () {
    local FILE="$1"
    case "$( file $FILE )" in
        *archive*)
            true
            ;;
        *)
            false
            ;;
    esac
}

#=head2 fw4ex_is_symbol_defined 

# This predicate checks whether a file (that may be given as argument
# to the C<nm> utility) defines a symbol.

#=cut

fw4ex_check_is_symbol_defined () {
    local FILE="$1"
    local NAME="$2"
    cat <<EOF
<p>Je cherche si <code>$FILE</code> définit bien 
le nom <code>$NAME</code>.
EOF
    if nm "$FILE" | fgrep -q "T $NAME"
    then
        echo "C'est bien le cas!"
    else
        nm $file
        cat <<EOF
<error>Le symbole <code>$NAME</code> n'est pas défini dans le
fichier <code>$FILE</code>!</error>
EOF
    fi
    echo "</p>"
}

#=head2 fw4ex_has_type

# This predicate takes a filename and a string (the expected type of
# the file) and checks whether this file has this type. The type is
# determined with the C<file> utility. For example, to check whether a
# file is a TeX DVI file, one should write 

#   fw4ex_has_type someFile 'TeX DVI'

# Pay attention, the C<file> utility depends on the current LANG.

#=cut

fw4ex_has_type () {
    local FILE=$1
    local TYPE="$2"
    if [[ ! -f $FILE ]]
    then
        cat <<EOF
<error> 
Le fichier <code>$FILE</code> n'existe pas!
</error>
EOF
        false
    else
        #local MAGIC_NUMBER=$( od -Anone -c -N2 $FILE | tr -d ' ' )
        #if [[ "$MAGIC_NUMBER" = '367002' ]]
        file $FILE > $TMPDIR/file
        if grep -qi "$TYPE" < $TMPDIR/file
        then  
            true
        else
            cat <<EOF
<error>
Votre fichier <code>$FILE</code> n'est pas un fichier de
type <code>$TYPE</code>, l'utilitaire <code>file</code> dit que c'est 
<code>$( fw4ex_transcode_carefully < $TMPDIR/file )</code>.
</error>
EOF
            false
        fi
    fi
}

#=head2 fw4ex_creation_hour 

# This small and internal function returns the creation time of a file
# but only the hour, minute and second part that is, something like
# C<16:10:53.000000000>. This is useful to check whether C<make>
# recreates a file or not.

#=cut

fw4ex_creation_hour () {
    local FILE="$1"
    ls --full-time "$FILE" | awk '{print $7}'
}

#=head2 fw4ex_is_impacted

# This internal predicate takes two filenames: a target and a
# requisite and checks whether the target is rebuilt when the
# requisite is touched. This proves that the target is indeed
# dependent on the requisite.

#=cut

fw4ex_is_impacted () {
    local TARGET="$1"
    local REQUISITE="$2"
    local OLDHOUR="$( fw4ex_creation_hour "$TARGET" )"
    sleep 1  # less than 1 second may be ignored
    touch "$REQUISITE"
    fw4ex_run_student_command $MAKE "$TARGET"
    local NEWHOUR="$( fw4ex_creation_hour "$TARGET" )"
    [ "$OLDHOUR" != "$NEWHOUR" ]
}

#=head2 fw4ex_check_impact 

# This function takes, as arguments, a filename (a target) followed by
# a number of requisites. It checks and verbalizes (in French) whether
# the target depends on the requisite with help of the
# C<fw4ex_is_impacted> predicate.

#=cut

fw4ex_check_impact () {
    local TARGET="$1"
    shift
    local RESULT=true
    for REQUISITE in "$@"
    do
      cat <<EOF
<p>
Je vérifie si <code>$TARGET</code> dépend de 
<code>$REQUISITE</code>. Je "touche" (comme l'on dit) 
<code>$REQUISITE</code> puis je demande à reconstruire 
<code>$MAKE $TARGET</code>.
EOF
      fw4ex_is_impacted "$TARGET" "$REQUISITE"
      local STATUS=$?
      fw4ex_show_student_raw_result
      if [[ $STATUS -eq 0 ]]
      then 
          echo "Le fichier <code>$TARGET</code> a été reconstruit. "
      else 
          cat <<EOF
Le fichier <code>$TARGET</code> n'a pas changé!
Il ne dépend donc pas de <code>$REQUISITE</code>.
EOF
          RESULT=false
      fi
    done
    echo "</p>"
    $RESULT
}

#=head2 fw4ex_clean_target

# Before testing that C<make> builds a file, it is safer to be sure
# that the intended file does not exist. This function removes all the
# mentioned targets and verbalizes this fact.

#=cut

fw4ex_clean_target () {
    for FILE in "$@"
    do
      if [[ -f "$FILE" ]] 
      then
          cat <<EOF
<p>Je vois que vous avez un fichier <code>$FILE</code>, 
je l'efface.</p>
EOF
          rm -f "$FILE"
      fi
    done
}

#=head2 fw4ex_make_once

# This function takes a target and runs the C<make> command to build
# or rebuild that target. If FW4EX_SHOW_ERROR_CODE is true, the error
# code of the C<make> is displayed if erroneous. The C<make> command
# is run with C<fw4ex_run_student_command> and as such leaves the
# stdout, stderr and error code as usual.

#=cut

FW4EX_SHOW_ERROR_CODE=false

fw4ex_make_once () {
    cat <<EOF
<p>Avant de demander l'exécution de <code>$MAKE $@</code>, je demande
à voir ce qui va être fait avec <code>$MAKE -n --no-print-directory $@</code>:
<pre>
EOF
    $MAKE -n --no-print-directory "$@" | fw4ex_transcode_carefully
    cat <<EOF
</pre>
J'exécute maintenant la commande <code>$MAKE $@</code>.
EOF
    fw4ex_run_student_command $MAKE "$@"
    local errcode=$( cat $TMPDIR/.lastExitCode )
    if ${FW4EX_SHOW_ERROR_CODE:-false}
    then
        if [[ $errcode -ne 0 ]]
        then 
            cat <<EOF
<warning>Votre commande <code>$MAKE $@</code> a retourné le code
$errcode.</warning>
EOF
            fw4ex_verbalize_error_code $TMPDIR/.lastExitCode
        fi
    fi
    echo "</p>"
    return $errcode
}

#=head2 fw4ex_re_make

# This predicate takes a target and rebuilds it with C<make>. It
# returns true iff nothing is done that is, the target is up to date.
# This predicate verbalizes its actions in French.

#=cut

fw4ex_re_make () {
    local TARGET="$1"
    shift
    local OLDHOUR="$( fw4ex_creation_hour $TARGET )"
    cat <<EOF
<p> Je demande à nouveau à voir ce qui sera fait avec la commande 
<code>$MAKE -n --no-print-directory $TARGET $@</code>: <pre>
EOF
    $MAKE -n --no-print-directory $TARGET "$@" | \
        tee $TMPDIR/result.s | fw4ex_transcode_carefully
    cat <<EOF
</pre></p>
EOF
    # If the target is already up to date, don't run make!
    if grep -Eq "^make:.*$TARGET.*(is up to date|est .* jour)" < $TMPDIR/result.s
    then :
    else
        cat <<EOF
<p>J'exécute maintenant la commande <code>$MAKE $TARGET $@</code>.</p>
EOF
        fw4ex_run_student_command $MAKE $TARGET "$@"
        fw4ex_show_student_raw_result
        if ${FW4EX_SHOW_ERROR_CODE:-false}
        then
            local errcode=$( cat $TMPDIR/.lastExitCode )
            if [[ $errcode -ne 0 ]]
            then 
                cat <<EOF
<warning>Votre commande <code>$MAKE $TARGET $@</code> a retourné le code
$errcode.</warning>
EOF
            fi
        fi
    fi

    if grep -Eq "^make:.*$TARGET.*(is up to date|est .* jour)" < $TMPDIR/result.s
    then
        cat <<EOF
<p>Le fichier <code>$TARGET</code> est bien à jour et rien n'a été
effectué: c'est parfait.</p>
EOF
        true
    else
        local NEWHOUR="$( fw4ex_creation_hour $TARGET )"
        if [[ "$OLDHOUR" == "$NEWHOUR" ]]
        then 
            cat <<EOF
<p> L'utilitaire <code>$MAKE</code> a refait quelque-chose mais la date 
de création de la cible <code>$TARGET</code> est toujours la même. </p>
EOF
            true
        else
            cat <<EOF
<error>Le fichier <code>$TARGET</code> a changé d'heure de
création. C'était $OLDHOUR, c'est maintenant $NEWHOUR.</error>
EOF
            false
        fi
    fi
}

#=head2 fw4ex_show_current_directory 

# Display the content of the current directory. This is often useful
# before running a make command. This command also stores the content
# of the directory in the C<TMPDIR/ls.before> file.

#=cut

fw4ex_show_current_directory () {
   echo "<p> Voici le contenu du répertoire courant: <pre>"
   ls -gG | fw4ex_transcode_carefully
   ls -1 > $TMPDIR/ls.before
   echo "</pre></p>"
}

#=head2 fw4ex_show_current_directory_after

# Display the content of the current directory. This is often useful
# after running a make command. This command also stores the content
# of the directory in the C<TMPDIR/ls.after> file.

#=cut

fw4ex_show_current_directory_after () {
   echo "<p> Voici le nouveau contenu du répertoire courant: <pre>"
   ls -gG | fw4ex_transcode_carefully
   ls -1 > $TMPDIR/ls.after
   echo "</pre></p>"
}

# Local Variables: ##
# coding:utf-8 ##
# End: ##
# end of makefileLib.sh
