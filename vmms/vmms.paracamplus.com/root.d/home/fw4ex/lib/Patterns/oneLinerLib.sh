#! /bin/bash
# Additional library for authors of exercises for FW4EX. This is
# the support library for the oneLinerPattern.sh
# This library should be sourced.

# NOTE: this is dead code! The real functions are the ones from runnerlib.

# Define these functions to report problems to the student during the
# phasis where expectations are checked.

fw4ex_report_present_file() {
    local FILE="$1"
    fw4ex_generate_xml_comment checked presence of $FILE
    if [[ ! -r "$FILE" ]]
    then 
        chmod a+r "$FILE"
    fi
    if [[ ! -s "$FILE" ]]
    then
        cat <<EOF
<error>Votre réponse est vide! </error>
EOF
        exit 0 # abort question!
    fi
}

fw4ex_report_missing_file() {
    local FILE="$1"
    cat <<EOF
<error>Vous ne m'avez donné aucune réponse! </error>
EOF
    # Abort question is automatic
}


fw4ex_report_present_directory() {
    local DIR="$1"
    fw4ex_generate_xml_comment checked presence of $DIR/
}

fw4ex_report_missing_directory() {
    local DIR="$1"
    cat <<EOF
<error>Je ne trouve pas de répertoire nommé <code>$DIR</code>! </error>
EOF
    # Abort question is automatic
}

# end of oneLinerLib.sh
