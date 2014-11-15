#! /bin/bash
# Runs on the Docker host in the ./Docker/ directory as the current user.
# Specific version for Marking Driver

RSYNC_FLAGS='
 --exclude RCS --exclude CVS --exclude .svn --exclude .hg --exclude .git 
 --exclude Archive --exclude=.DS_Store --exclude=notes.QNC
 --exclude=*~ --exclude=.\#* --exclude=\#*\# --exclude=*.bak
 --exclude=*.sql.gz --exclude=disk*\.qcow2 --exclude=EclipseWS '

echo "Preparing root HOME"
TODIR=$ROOTDIR/root/fw4exrootlib
mkdir -p $TODIR
# In fact, we just need fw4exrootlib/fw4exms.sh
rsync -avuL $RSYNC_FLAGS ../Mlib/fw4exrootlib/ $TODIR/

echo "Final cleanup"
rm -f $(find $ROOTDIR -name '*~')

# end of prepare-55-fw4exContent.sh
