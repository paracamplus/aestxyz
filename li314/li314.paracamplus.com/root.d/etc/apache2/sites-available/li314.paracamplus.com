<VirtualHost *:80>
# Check syntax with /usr/sbin/apache2ctl -t
# generated on 2014-10-05T15:47:28
# Catalyst needs apache2-mpm-prefork!

  ServerName  li314.paracamplus.com
  ServerAdmin fw4exmaster@paracamplus.com
  DocumentRoot /var/www/li314.paracamplus.com/
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

        <Directory /var/www/li314.paracamplus.com/ >
                Order allow,deny
                allow from all
        </Directory>

# Beware: Location directives are sorted from less precise to most precise
PerlModule Paracamplus::FW4EX::LI314::li314_paracamplus_com

        <Location / >
              SetHandler modperl
              PerlResponseHandler Paracamplus::FW4EX::LI314::li314_paracamplus_com
              Order allow,deny
              allow from all
# FUTURE limit number of request/second
        </Location>

        <Location /favicon.ico>
              SetHandler default_handler
              ExpiresDefault A2592000
        </Location>

        Alias /static/ /var/www/li314.paracamplus.com/static/
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

        RedirectMatch /a/(.*)$ http://a.paracamplus.com/$1
        RedirectMatch /e/(.*)$ http://e.paracamplus.com/$1
        RedirectMatch (/s/.*)$ http://s.paracamplus.com/$1
        RedirectMatch /x/(.*)$ http://x.paracamplus.com/$1

        # Coalesce all problems in one place:
        Errorlog /var/log/apache2/error.log

        # Possible values include: debug, info, notice, warn, error, crit,
        # alert, emerg.
        LogLevel warn

        CustomLog /var/log/apache2/li314.paracamplus.com-access.log combined
        ServerSignature On

</VirtualHost>
