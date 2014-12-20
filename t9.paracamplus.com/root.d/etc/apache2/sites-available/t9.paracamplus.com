<VirtualHost *:80>
# This is the Apache configuration on the Docker host.
# Check syntax with /usr/sbin/apache2ctl -t

  ServerName  t9.paracamplus.com
  ServerAdmin fw4exmaster@paracamplus.com
  DocumentRoot /var/www/t9.paracamplus.com/
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

        <Directory /var/www/t9.paracamplus.com/ >
                Order allow,deny
                allow from all
        </Directory>

        <Directory /var/www/t9.paracamplus.com/static/ >
                Order allow,deny
                allow from all
                FileETag none
                ExpiresActive On
                # expire images after 30 hours
                ExpiresByType image/gif A108000
                ExpiresByType image/png A108000
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
        ProxyPass /   http://localhost:54980/

# <Location> directives should be sorted from less to most precise:

        <Location /favicon.ico>
              SetHandler default_handler
              ExpiresDefault A2592000
        </Location>

        Alias /static/ /var/www/t9.paracamplus.com/static/
        <Location /static/ >
                SetHandler default_handler
        </Location>

        Errorlog /var/log/apache2/t9.paracamplus.com-error.log

        # Possible values include: debug, info, notice, warn, error, crit,
        # alert, emerg.
        LogLevel warn

        CustomLog /var/log/apache2/t9.paracamplus.com-access.log combined
        ServerSignature On

</VirtualHost>

# Tests
# url retransmise au serveur S:
# wget -S -o /dev/stdout -O /dev/null http://t.paracamplus.com/s/9/9/9/F/9/4/E/6/4/5/E/E/1/1/E/3/B/D/B/0/A/A/C/C/3/2/B/5/C/0/9/6/999F94E6-45EE-11E3-BDB0-AACC32B5C096.xml

# url servie directement par t:
# wget -S -o /dev/stdout -O /dev/null http://t.paracamplus.com/static/5-1.gif

# transmis telle quelle a Docker (mais ne devrait pas):
# wget -S -o /dev/stdout -O /dev/null http://t.paracamplus.com/favicon.ico

# transmis telle quelle a Docker:
# wget -S -o /dev/stdout -O /dev/stdout http://t.paracamplus.com/ | head -40
