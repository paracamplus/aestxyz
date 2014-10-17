#! /bin/bash
# Additional library for authors of exercises for FW4EX.
# This library should be sourced.
source $FW4EX_LIB_DIR/Patterns/comparisonLib.sh

# Hypotheses:
#   la commande a tester est dans COMMAND
#   les fichiers de donnees sont dans tests/*.data
#   les options fournies par l'etudiant sont dans le fichier ./options
#   [c'est ce que fournit la webapp OneLiner]
#   les options solution sont dans l'exercice en pseudos/perfect/options
#   les resultats de l'etudiant sont normalises avec le filtre NORMALIZER
#   [mais seulement si la variable est definie.]

# FUTURE: et pourquoi pas cette page en TT ou en php ???

# Dans quel fichier se trouvent les options de l'etudiant:
OPTIONS=${OPTIONS:-options}
# Dans quel fichier se trouvent les options solution:
SOLUTION=${SOLUTION:-$FW4EX_EXERCISE_DIR/pseudos/perfect/$OPTIONS}

# Verifier que les options ne debutent pas par COMMAND
CHECK_OPTIONS=${CHECK_OPTIONS:-true}

# Ou sont les fichiers de donnees ?
DATA_DIR=${DATA_DIR:-$FW4EX_EXERCISE_DIR/tests}
DATA_SUFFIX=${DATA_SUFFIX:-data}

# Comment normaliser les resultats avant comparaison.
# Ne pas definir NORMALIZER si l'on n'en a pas besoin.

# Par defaut on utilise une distance de Levenshtein. On peut aussi
# utiliser une comparaison par ligne (constante 'line'):
COMPARISON=${COMPARISON:-char}

# Pour mettre certains details en commentaires html
DEBUG=${DEBUG:-false}

# On pourra aussi dans WIN_FORMULA utiliser la variable DATA_NUMBER

# ###################################################################
# Que le fichier 'options' existe et n'est pas vide est deja verifie!

# -1- ###################################################################
# Retour vers l'etudiant des options qu'il a choisies:
fw4ex_show_command_and_options_from_file "$COMMAND" "$OPTIONS"

# -2- ###################################################################
# Hack! Quelquefois les etudiants inserent le nom de la commande en
# tete des options. On leur signifie leur erreur!
if $CHECK_OPTIONS
then
    fw4ex_check_options_prefixed_by_command "$COMMAND" "$OPTIONS"
fi

# -3- ###################################################################
# Executer et comparer
# le nombre de fichiers de donnees a tester. Chaque test rapportera
# 1/$DATA_NUMBER point (c'est specifie dans WIN_FORMULA).
DATA_NUMBER=$( ls -1 $DATA_DIR/*.${DATA_SUFFIX} | wc -l )
cat <<EOF
<p>
Je vais comparer votre solution et la mienne sur $DATA_NUMBER fichiers
de données.
</p>
EOF

I=0
# On itere sur toutes les configurations de tests:
for data in $DATA_DIR/*.${DATA_SUFFIX}
do 
    I=$(( $I+1 ))
    # -3a- Decrire la configuration de test
    echo "<section rank='$I'>"
    fw4ex_show_data_file $I "$data"

    # -3b- tourner la commande de l'etudiant
    fw4ex_run_student_command_and_options_from_file \
        "$COMMAND" "$OPTIONS" < "$data"
    fw4ex_show_student_raw_result
    # Possible hook for authors:
    fw4ex_after_student_run_hook $I "$data"

    # -3c- tourner la commande de l'auteur
    # Si les options de l'auteur provoquent des anomalies ou si le
    # normaliseur en provoque, les erreurs sont emises sur le stderr
    # qui, non vide, sera signale a l'auteur.
    fw4ex_run_teacher_command_and_options_from_file \
        "$COMMAND" "$SOLUTION" < "$data"
    fw4ex_show_teacher_raw_result
    fw4ex_after_teacher_run_hook $I "$data"

    # -3d- normaliser
    if [[ -n "$NORMALIZER" ]]
    then
        fw4ex_normalize_and_show_results
    fi

    # -3e- comparer et donner des points
    case "${COMPARISON}" in 
        char)
            fw4ex_compare_results_as_strings
            ;;
        line)
            fw4ex_compare_results_as_lines
            ;;
        *)
            echo "Cannot find such a comparison ($COMPARISON) ?" 1>&2
            exit 101
            ;;
    esac
    # FIXME: would not be emitted in case of prior exit!!!!!!!!!
    echo "</section>"

done

cat <<EOF
<p>
Fin de correction automatique.
</p>
EOF

# Local Variables: ##
# coding:utf-8 ##
# End: ##
# end of oneLinerPattern.sh
