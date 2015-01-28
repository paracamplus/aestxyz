#! /bin/bash
# Runs on Youpou as root.

cd ${0%/*}/

PERLLIB_DIR=/usr/local/lib/site_perl/Paracamplus/ExerciseFrameWork

export PERL5LIB=${PERLLIB_DIR}/perllib:/usr/lib/perl5:/usr/share/perl5:/usr/lib/perl/5.18:/usr/share/perl/5.18

./md-start.pl \
    --reload \
    --nodebug \
    --conf ./md-dockerMS-config.yml \
	--version="0" \
	--life=$(( 60 * 60 * 24 * 365 ))

# end of run.md.with.docker.ms.sh
