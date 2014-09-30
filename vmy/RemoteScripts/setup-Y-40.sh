#! /bin/bash

# Remove other Apache configuration files. Configurations with the
# domain paracamplus.net are used for test.
(
    cd /etc/apache2/sites-enabled/
    rm -f *.paracamplus.net
)

# end of setup-Y-40.sh
