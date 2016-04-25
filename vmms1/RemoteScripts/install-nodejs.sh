#! /bin/bash -x
# Runs as root in the Marking Slave container. Install Node.js

NODETGZ=$(ls -t1 /opt/TGZ/node*gz | head -n1)

# we install nodejs in /usr/local/bin
cd /usr/local

if [ -f "bin/node" -a -x bin/node ]
then
    VERSION="$(bin/node -v)"
    case "$NODETGZ" in
        *$VERSION*)
            echo "nodejs $VERSION already installed."
            exit
            ;;
        *)
            echo "Install another version of node $VERSION..."
            (cd bin ; rm -rf node npm)
            ;;
    esac
fi

echo "Installing $NODETGZ ..."
tar --strip-components 1 -xzf ${NODETGZ}

if /usr/local/bin/node --version
then
    :
else
    echo "node does not seem to work!"
    exit 22
fi

if node --version
then
    :
else
    echo "node does not seem to be in the PATH!"
    exit 22
fi

# end of install-nodejs.sh
