<VirtualHost *:80>
# This is the Apache configuration on the Docker host
# Check syntax with /usr/sbin/apache2ctl -t

  ServerName  mooc-li101-2014fev.paracamplus.com
              # temporary:
              ServerAlias mooc-li101-2014fev.fw4ex.org
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
        </Directory>

# <Location> directives should be sorted from less to most precise:

        <Location / >
              Order allow,deny
              allow from all
              # FUTURE limit the number of requests/second
              # Relay to the Docker container
              ProxyPass        http://localhost:60080/
              ProxyPassReverse http://localhost:60080/
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

        Errorlog /var/log/apache2/mooc-li101-2014fev.paracamplus.com-error.log

        # Possible values include: debug, info, notice, warn, error, crit,
        # alert, emerg.
        LogLevel warn

        CustomLog /var/log/apache2/mooc-li101-2014fev.paracamplus.com-access.log combined
        ServerSignature On

</VirtualHost>
