#! /bin/bash
# Runs on Bijou with the most current version of Perl modules.

cd ${0%/*}/

# Use the development library:
PERLLIB_DIR=/home/queinnec/Paracamplus/ExerciseFrameWork

export PERL5LIB=${PERLLIB_DIR}/perllib:/usr/lib/perl5:/usr/share/perl5:/usr/lib/perl/5.18:/usr/share/perl/5.18

./md-start.pl \
    --reload \
    --nodebug \
    --conf ./md-dockerMS-config.yml \
	--version="1" \
	--life=$(( 60 * 60 * 24 * 365 ))

# end of run.md.with.docker.ms.sh
