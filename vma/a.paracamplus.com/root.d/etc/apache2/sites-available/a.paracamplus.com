<VirtualHost *:80>
# Apache configuration on Docker container

# Check syntax with /usr/sbin/apache2ctl -t
# Catalyst needs apache2-mpm-prefork!

  ServerName  a.paracamplus.com
  ServerAlias a0.paracamplus.com
  ServerAlias a1.paracamplus.com
  ServerAlias a2.paracamplus.com
  ServerAlias a3.paracamplus.com
  ServerAlias a4.paracamplus.com
  ServerAlias a5.paracamplus.com
  ServerAlias a6.paracamplus.com
  ServerAlias a7.paracamplus.com
  ServerAlias a8.paracamplus.com
  ServerAlias a9.paracamplus.com
  ServerAdmin fw4exmaster@paracamplus.com
  DocumentRoot /var/www/a.paracamplus.com/
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

        <Directory /var/www/a.paracamplus.com/ >
                Order allow,deny
                allow from all
                Header append 'X-originator' 'docker A'
        </Directory>

# Beware: Location directives are sorted from less precise to most precise
SetEnv FW4EX_CONFIG_YML /opt/a.paracamplus.com/a.paracamplus.com.yml
PerlModule Paracamplus::FW4EX::A

        <Location / >
              SetHandler modperl
              PerlResponseHandler Paracamplus::FW4EX::A
              Order allow,deny
              allow from all
# FUTURE limit number of request/second
        </Location>

        <Location /favicon.ico>
              SetHandler default_handler
              ExpiresDefault A2592000
        </Location>

        Alias /static/ /var/www/a.paracamplus.com/static/
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

        CustomLog /var/log/apache2/a.paracamplus.com-access.log combined
        ServerSignature On

</VirtualHost>
