<VirtualHost *:80>
# This is the Apache configuration of the Docker container.
# Check syntax with /usr/sbin/apache2ctl -t
# generated on 2014-10-03T19:48:22
# Catalyst needs apache2-mpm-prefork!

  ServerName  t.paracamplus.com
  ServerAlias t0.paracamplus.com
  ServerAlias t1.paracamplus.com
  ServerAlias t2.paracamplus.com
  ServerAlias t3.paracamplus.com
  ServerAlias t4.paracamplus.com
  ServerAlias t5.paracamplus.com
  ServerAlias t6.paracamplus.com
  ServerAlias t7.paracamplus.com
  ServerAlias t8.paracamplus.com
  ServerAlias t9.paracamplus.com
  ServerAdmin fw4exmaster@paracamplus.com
  DocumentRoot /var/www/t.paracamplus.com/
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

        <Directory /var/www/t.paracamplus.com/ >
                Order allow,deny
                allow from all
        </Directory>

# Beware: Location directives are sorted from less precise to most precise
PerlModule Paracamplus::FW4EX::T::t_paracamplus_com

        <Location / >
              SetHandler modperl
              PerlResponseHandler Paracamplus::FW4EX::T::t_paracamplus_com
              Order allow,deny
              allow from all
# FUTURE limit number of request/second
        </Location>

        <LocationMatch "/+favicon.ico">
              SetHandler default_handler
              ExpiresDefault A2592000
        </LocationMatch>

        AliasMatch "^/+static/+(.*)$" /var/www/t.paracamplus.com/static/$1
        <LocationMatch "/+static/+" >
                SetHandler default_handler
                FileETag none
                ExpiresActive On
                # expire images after 30 hours
                ExpiresByType image/gif A108000
                ExpiresByType image/png A108000
                # expires css and js after 30 hours
                ExpiresByType text/css        A108000
                ExpiresByType text/javascript A108000
        </LocationMatch>

        ProxyPass     /a/      http://a.paracamplus.com/
        ProxyPass     /s/      http://s.paracamplus.com/
        ProxyPass     /x/      http://x.paracamplus.com/
        ProxyPass     /e/      http://e.paracamplus.com/

        # Coalesce all problems in one place:
        Errorlog /var/log/apache2/error.log

        # Possible values include: debug, info, notice, warn, error, crit,
        # alert, emerg.
        LogLevel warn

        CustomLog /var/log/apache2/t.paracamplus.com-access.log combined
        ServerSignature On

</VirtualHost>
