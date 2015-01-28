<VirtualHost *:80>
# This is the Apache configuration on the Docker host.
# Check syntax with /usr/sbin/apache2ctl -t

  ServerName  li314.paracamplus.com
              # temporary:
              ServerAlias li314.fw4ex.org
  ServerAdmin fw4exmaster@paracamplus.com
  DocumentRoot /var/www/li314.paracamplus.com/
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

        <Directory /var/www/li314.paracamplus.com/ >
                Options +FollowSymLinks
                Order allow,deny
                allow from all
        </Directory>

        <Directory /var/www/li314.paracamplus.com/static/ >
              Options +FollowSymLinks
              Order allow,deny
              allow from all
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

# ProxyPass must be sorted from most precise to less precise:
        ProxyPass /s/ http://s.paracamplus.com/s/
        ProxyPass /a/ http://a.paracamplus.com/
        ProxyPass /x/ http://x.paracamplus.com/
        ProxyPass /e/ http://e.paracamplus.com/
        ProxyPass /static/ !
        ProxyPass /favicon.ico !
        ProxyPass /   http://localhost:55080/
# FUTURE limit the number of requests/second

# <Location> directives should be sorted from less to most precise:

        <Location /favicon.ico>
              Header append 'X-originator' 'Apache2 li314'
              SetHandler default_handler
              ExpiresDefault A2592000
        </Location>

        Alias /static/ /var/www/li314.paracamplus.com/static/
        <Location /static/ >
              Header append 'X-originator' 'Apache2 LI314'
              SetHandler default_handler
        </Location>

        Errorlog /var/log/apache2/li314.paracamplus.com-error.log

        # Possible values include: debug, info, notice, warn, error, crit,
        # alert, emerg.
        LogLevel warn

        CustomLog /var/log/apache2/li314.paracamplus.com-access.log combined
        ServerSignature On

</VirtualHost>

# Tests
# url retransmise au serveur S:
# wget -S -o /dev/stdout -O /dev/null http://li314.paracamplus.com/s/9/9/9/F/9/4/E/6/4/5/E/E/1/1/E/3/B/D/B/0/A/A/C/C/3/2/B/5/C/0/9/6/999F94E6-45EE-11E3-BDB0-AACC32B5C096.xml

# url servie directement par li314:
# wget -S -o /dev/stdout -O /dev/null http://li314.paracamplus.com/static/t.xsl

# transmis telle quelle a Docker:
# wget -S -o /dev/stdout -O /dev/null http://li314.paracamplus.com/favicon.ico

# wget -S -o /dev/stdout -O /dev/stdout http://li314.paracamplus.com/ | head -40
