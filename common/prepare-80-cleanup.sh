#! /bin/bash
# Runs on the Docker host as the current user.
# Just remove from root.d backup files

echo 'Removing *~ files'
rm -f $(find $ROOTDIR -type f -name '*~')

# end of prepare-80-cleanup.sh
