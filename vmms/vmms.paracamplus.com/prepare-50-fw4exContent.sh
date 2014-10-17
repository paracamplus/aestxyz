#! /bin/bash
# Runs on the Docker host in the ./Docker/ directory as the current user.

RSYNC_FLAGS='
 --exclude RCS --exclude CVS --exclude .svn --exclude .hg --exclude .git 
 --exclude Archive --exclude=.DS_Store --exclude=notes.QNC
 --exclude=*~ --exclude=.\#* --exclude=\#*\# --exclude=*.bak
 --exclude=*.sql.gz --exclude=disk*\.qcow2 --exclude=EclipseWS '

echo "Preparing root HOME"
TODIR=$ROOTDIR/root
rsync -avuL $RSYNC_FLAGS ../Mlib/fw4exrootlib $TODIR/
rsync -avuL $RSYNC_FLAGS ../Servers/.ssh $TODIR/.sshnew

echo "Preparing fw4ex HOME"
TODIR=$ROOTDIR/home/fw4ex
mkdir -p $TODIR
rsync -avuL $RSYNC_FLAGS ../Mlib/fw4exlib $TODIR/
rm -rf $TODIR/EclipseWS

mkdir -p $TODIR/lib
rsync -avuL $RSYNC_FLAGS ../Mlib/authorlib/ $TODIR/lib/

mkdir -p $TODIR/bin
mkdir -p $TODIR/C
for d in Confiner Transcoder
do
    rsync -avuL $RSYNC_FLAGS ../C/$d $TODIR/C/
    rm -rf $TODIR/C/$d/bin
done

echo "Final cleanup"
rm -f $(find $ROOTDIR -name '*~')

# end of prepare-50-fw4exContent.sh
