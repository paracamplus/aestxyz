<VirtualHost *:80>
# This is the Apache configuration of the Docker container
# Check syntax with /usr/sbin/apache2ctl -t
# generated on 2014-10-05T15:47:28
# Catalyst needs apache2-mpm-prefork!

  ServerName  mooc-li101-2014fev.paracamplus.com
  ServerAdmin fw4exmaster@paracamplus.com
  DocumentRoot /var/www/mooc-li101-2014fev.paracamplus.com/
  AddDefaultCharset UTF-8

AddType text/javascript .js
AddType text/css        .css
AddType application/xslt+xml .xsl
ExpiresActive On

        <Directory />
                Options FollowSymLinks
                AllowOverride None
                Options -Indexes 
                Order deny,allow
                Deny from all
        </Directory>

        <Directory /var/www/mooc-li101-2014fev.paracamplus.com/ >
                Order allow,deny
                allow from all
                Header append 'X-originator' 'docker mooc-li101-2014fev'
        </Directory>

# Beware: Location directives are sorted from less precise to most precise

#PerlModule fills /opt/tmp with root:root thus preventing
#PerlModule Paracamplus::FW4EX::LI101

        <Location / >
              SetHandler modperl
              PerlResponseHandler Paracamplus::FW4EX::LI101
              Order allow,deny
              allow from all
# FUTURE limit number of request/second
        </Location>

        <Location /favicon.ico>
              SetHandler default_handler
              ExpiresDefault A2592000
        </Location>

        Alias /static/ /var/www/mooc-li101-2014fev.paracamplus.com/static/
        <Location /static/ >
                SetHandler default_handler
                FileETag none
                ExpiresActive On
                # expire images after 30 hours
                ExpiresByType image/gif A108000
                ExpiresByType image/png A108000
                # expires css and js after 30 hours
                ExpiresByType text/css        A108000
                ExpiresByType text/javascript A108000
        </Location>

        ProxyPass     /a/      http://a.paracamplus.com/
        ProxyPass     /s/      http://s.paracamplus.com/
        ProxyPass     /x/      http://x.paracamplus.com/
        ProxyPass     /e/      http://e.paracamplus.com/

        # Coalesce all problems in one place:
        Errorlog /var/log/apache2/error.log

        # Possible values include: debug, info, notice, warn, error, crit,
        # alert, emerg.
        LogLevel warn

        CustomLog /var/log/apache2/mooc-li101-2014fev.paracamplus.com-access.log combined
        ServerSignature On

</VirtualHost>
