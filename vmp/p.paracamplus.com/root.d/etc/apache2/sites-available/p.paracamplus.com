<VirtualHost *:80>
# Check syntax with /usr/sbin/apache2ctl -t
# generated on 2015-08-01T10:22:04
# Catalyst needs apache2-mpm-prefork!

  ServerName  p.paracamplus.com
  ServerAdmin fw4exmaster@paracamplus.com
  DocumentRoot /var/www/p.paracamplus.com/
  AddDefaultCharset UTF-8

AddType text/javascript .js
AddType text/css        .css
AddType application/xslt+xml .xsl
AddType image/vnd.microsoft.icon .ico
ExpiresActive On

        <Directory />
                AllowOverride None
                Options -Indexes 
                Order deny,allow
                Deny from all
        </Directory>

        <Directory /var/www/p.paracamplus.com/ >
                Options +FollowSymLinks
                Order allow,deny
                allow from all
        </Directory>

        <Directory /var/www/p.paracamplus.com/static/ >
              Options +FollowSymLinks
              Order allow,deny
              allow from all
              SetHandler default_handler
              FileETag none
              ExpiresActive On
              # expire images after 30 hours
              ExpiresByType image/gif A108000
              ExpiresByType image/png A108000
              ExpiresByType image/vnd.microsoft.icon A2592000
              # expires css and js after 30 hours
              ExpiresByType text/css        A108000
              ExpiresByType text/javascript A108000
        </Directory>

# Beware: ProxyPass must be sorted from most precise to less precise:
#        ProxyPass /static/ !
#        ProxyPass /favicon.ico !
#        ProxyPass /        http://localhost:XXX80/
# FUTURE limit the number of requests/second

# Beware: Location directives are sorted from less precise to most precise
PerlModule Paracamplus::FW4EX::P

        <Location / >
              SetHandler modperl
              PerlResponseHandler Paracamplus::FW4EX::P
              Order allow,deny
              allow from all
# FUTURE limit number of request/second
        </Location>

        <Location /favicon.ico>
              SetHandler default_handler
              ExpiresDefault A2592000
        </Location>

        Alias /static/ /var/www/p.paracamplus.com/static/
        <Location /static/ >
                SetHandler default_handler
        </Location>

        # Coalesce all problems in one place:
        Errorlog /var/log/apache2/error.log

        # Possible values include: debug, info, notice, warn, error, crit,
        # alert, emerg.
        LogLevel warn

        CustomLog /var/log/apache2/p.paracamplus.com-access.log combined
        ServerSignature On

</VirtualHost>
