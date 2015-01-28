<VirtualHost *:80>
# This is the Apache configuration on the Docker host.
# Here, t = t0

  ServerName t.paracamplus.com
  ServerAlias t0.paracamplus.com
              # temporary:
              ServerAlias t.fw4ex.org
  ServerAdmin fw4exmaster@paracamplus.com
  DocumentRoot /var/www/t.paracamplus.com/
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

        <Directory /var/www/t.paracamplus.com/ >
                Options +FollowSymLinks
                Order allow,deny
                allow from all
        </Directory>

        <Directory /var/www/t.paracamplus.com/static/ >
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

# ProxyPass must be sorted from most precise to less precise:
        ProxyPass /a/      http://a.paracamplus.com/
        ProxyPass /s/      http://s.paracamplus.com/
        ProxyPass /x/      http://x.paracamplus.com/
        ProxyPass /e/      http://e.paracamplus.com/
        ProxyPass /static/ !
        ProxyPass /favicon.ico !
        ProxyPass /        http://localhost:54080/
# FUTURE limit the number of requests/second

# <Location> directives should be sorted from less to most precise:

        <Location /favicon.ico>
              Header append 'X-originator' 'Apache2 t'
              SetHandler default_handler
              ExpiresDefault A2592000
        </Location>

        Alias /static/ /var/www/t.paracamplus.com/static/
        <Location /static/ >
              Header append 'X-originator' 'Apache2 T'
              SetHandler default_handler
        </Location>

        Errorlog /var/log/apache2/t.paracamplus.com-error.log

        # Possible values include: debug, info, notice, warn, error, crit,
        # alert, emerg.
        LogLevel warn

        CustomLog /var/log/apache2/t.paracamplus.com-access.log combined
        ServerSignature On

</VirtualHost>
