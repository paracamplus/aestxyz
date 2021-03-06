<VirtualHost *:80>
# Check syntax with /usr/sbin/apache2ctl -t

  ServerName  a6.paracamplus.com
  ServerAdmin fw4exmaster@paracamplus.com
  DocumentRoot /var/www/a6.paracamplus.com/
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

        <Directory /var/www/a6.paracamplus.com/ >
                Order allow,deny
                allow from all
        </Directory>

# <Location> directives should be sorted from less to most precise:

        <Location / >
              Order allow,deny
              allow from all
# FUTURE limit the number of requests/second
              # Relay to the Docker container
              ProxyPass        http://localhost:57080/
              ProxyPassReverse http://localhost:57080/
        </Location>

        <Location /favicon.ico>
              SetHandler default_handler
              ExpiresDefault A2592000
        </Location>

        Alias /static/ /var/www/a6.paracamplus.com/static/
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

        Errorlog /var/log/apache2/a6.paracamplus.com-error.log

        # Possible values include: debug, info, notice, warn, error, crit,
        # alert, emerg.
        LogLevel warn

        CustomLog /var/log/apache2/a6.paracamplus.com-access.log combined
        ServerSignature On

</VirtualHost>
