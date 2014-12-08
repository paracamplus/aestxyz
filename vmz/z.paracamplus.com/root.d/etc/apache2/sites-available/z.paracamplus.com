<VirtualHost *:80>
# Check syntax with /usr/sbin/apache2ctl -t
# generated on 2014-10-09T13:39:37
# Catalyst needs apache2-mpm-prefork!

  ServerName  z.paracamplus.com
  ServerAlias z0.paracamplus.com
  ServerAlias z1.paracamplus.com
  ServerAlias z2.paracamplus.com
  ServerAlias z3.paracamplus.com
  ServerAlias z4.paracamplus.com
  ServerAlias z5.paracamplus.com
  ServerAlias z6.paracamplus.com
  ServerAlias z7.paracamplus.com
  ServerAlias z8.paracamplus.com
  ServerAlias z9.paracamplus.com
  ServerAdmin fw4exmaster@paracamplus.com
  DocumentRoot /var/www/z.paracamplus.com/
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

        <Directory /var/www/z.paracamplus.com/ >
                Order allow,deny
                allow from all
        </Directory>

# Beware: Location directives are sorted from less precise to most precise
PerlModule Paracamplus::FW4EX::Z::z_paracamplus_com

        <Location / >
              SetHandler modperl
              PerlResponseHandler Paracamplus::FW4EX::Z::z_paracamplus_com
              Order allow,deny
              allow from all
# FUTURE limit number of request/second
        </Location>

        <Location /favicon.ico>
              SetHandler default_handler
              ExpiresDefault A2592000
        </Location>

        Alias /static/ /var/www/z.paracamplus.com/static/
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

        # Coalesce all problems in one place:
        Errorlog /var/log/apache2/error.log

        # Possible values include: debug, info, notice, warn, error, crit,
        # alert, emerg.
        LogLevel warn

        CustomLog /var/log/apache2/z.paracamplus.com-access.log combined
        ServerSignature On

</VirtualHost>
