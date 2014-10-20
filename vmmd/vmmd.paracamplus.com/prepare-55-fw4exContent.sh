#! /bin/bash
# Runs on the Docker host in the ./Docker/ directory as the current user.
# Specific version for Marking Driver

RSYNC_FLAGS='
 --exclude RCS --exclude CVS --exclude .svn --exclude .hg --exclude .git 
 --exclude Archive --exclude=.DS_Store --exclude=notes.QNC
 --exclude=*~ --exclude=.\#* --exclude=\#*\# --exclude=*.bak
 --exclude=*.sql.gz --exclude=disk*\.qcow2 --exclude=EclipseWS '

echo "Final cleanup"
rm -f $(find $ROOTDIR -name '*~')

# end of prepare-55-fw4exContent.sh
