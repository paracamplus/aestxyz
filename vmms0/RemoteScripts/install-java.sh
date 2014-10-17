#! /bin/bash
# Runs as root in the Marking Slave container. Install Java

JDKTGZ=$(ls -t1 /opt/TGZ/jdk* | head -n1)
JDK=${JDKTGZ%.tgz}
JDK=${JDK##*/}

# We install Java in /usr/local/bin
mkdir -p /usr/local/bin
cd /usr/local/bin

if [ -f "$JDK" -a -x ./java ]
then 
    echo "Java ($JDK) already installed."
    exit
fi

echo "Installing $JDKTGZ ..."
rm -rf jdk* 2>/dev/null

case "$JDK" in
    *.bin)
        # (re-)install jdk in /usr/local/bin/jdk*/
        yes | bash $JDKTGZ > /dev/null
        ;;
    *.tar.gz)
        tar xzf $JDKTGZ
        ;;
    *)
        echo "Unknown way to install java from $JDK"
        exit 20
        ;;
esac

ln -sf jdk*/bin/* .

# Let's get out of /usr/local/bin to check whether java can be run:
cd

if java -version 2>&1 | grep -i 'runtime environment'
then 
    # Gain some space
    ( 
        cd /usr/local/bin/jdk*/
        rm -rf demo/plugin/
        rm -rf demo/applets/
        rm -rf db/javadb/javadoc/
        rm -rf db/javadb/docs/html/
    ) 2>/dev/null
    touch /usr/local/bin/$JDK
else
    echo "java does not seem to work!"
    exit 22
fi

# install the orgFW4EXjunitTest library
mkdir -p /home/fw4ex/lib
cp -p /opt/TGZ/orgFW4EXjunitTest.jar /home/fw4ex/lib/
chown fw4ex: /home/fw4ex/lib/orgFW4EXjunitTest.jar
chmod 444 /home/fw4ex/lib/orgFW4EXjunitTest.jar

# end of setup-36-java.sh
