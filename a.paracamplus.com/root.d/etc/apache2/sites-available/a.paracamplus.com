<VirtualHost *:80>
# Version avec equilibreur de charges entre a0 et a1.

  ServerName  a.paracamplus.com
              # temporary:
              ServerAlias a.fw4ex.org
              ServerAlias a4.fw4ex.org
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
        </Directory>

        ProxyRequests off
        <Proxy balancer://mycluster>
                BalancerMember http://a0.paracamplus.com
                BalancerMember http://a1.paracamplus.com
                Order Deny,Allow
                Deny from none
                Allow from all
                ProxySet lbmethod=byrequests
        </Proxy>
        ProxyPass        / balancer://mycluster/
        ProxyPassReverse / balancer://mycluster/

        Errorlog /var/log/apache2/a.paracamplus.com-error.log

        # Possible values include: debug, info, notice, warn, error, crit,
        # alert, emerg.
        LogLevel warn

        CustomLog /var/log/apache2/a.paracamplus.com-access.log combined
        ServerSignature On

</VirtualHost>
