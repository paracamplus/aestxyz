#! /bin/bash
# This script runs in a Docker container and tries to set up a 
# connection towards the database.

DBHOST=db.paracamplus.com
DBSOCKET=/var/run/postgresql/.s.PGSQL.5432

# There are numerous ways to access the database:
# (1) open a tcp connection towards the database host
#     this requires pg_hba.conf to accept it.
# (2) open the named socket if the database runs on the Docker host
#     
# (3)

checkSocket () {
    if [ -u $DBSOCKET ]
    then
        echo $DBHOST
    fi
}



# end of lookfordb.sh
