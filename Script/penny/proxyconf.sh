#!/bin/bash

echo "=== INSTALL APACHE MODULE ==="
a2enmod rewrite
a2enmod proxy
a2enmod proxy_http
a2enmod proxy_balancer
a2enmod lbmethod_byrequests
a2enmod headers

echo "=== CONFIGURE PENNY ==="

cat > /etc/apache2/sites-available/reverse-proxy.conf <<'EOF'
<VirtualHost *:80>

    # =========================
    # REDIRECT KANONIK PENNY
    # =========================
    RewriteEngine On

    RewriteCond %{HTTP_HOST} ^192\.228\.50\.2$ [OR]
    RewriteCond %{HTTP_HOST} ^penny\.K34\.com$ [NC]
    RewriteRule ^/$ http://www.K34.com/ [R=301,L]


    # =========================
    # BASIC AUTH /admin
    # =========================
    Alias /admin /var/www/admin

    <Directory /var/www/admin>
        AuthType Basic
        AuthName "Restricted Area"
        AuthUserFile /etc/apache2/.htpasswd
        Require valid-user
    </Directory>

    ProxyPass /admin !


    # =========================
    # REVERSE PROXY VAULT
    # =========================
    <Proxy "balancer://vault">
        BalancerMember http://192.228.10.6
        BalancerMember http://192.228.10.7
    </Proxy>

    ProxyPass        / balancer://vault/
    ProxyPassReverse / balancer://vault/


    # =========================
    # FORWARD CLIENT IDENTITY
    # =========================
    ProxyPreserveHost On
    RequestHeader set X-Real-IP "%{REMOTE_ADDR}s"

</VirtualHost>
EOF

echo "=== ENABLE SITE ==="
a2dissite 000-default.conf
a2ensite reverse-proxy.conf

echo "=== CHECK APACHE ==="
apache2ctl configtest

if [ $? -ne 0 ]; then
    echo "ERROR: Apache configuration invalid!"
    exit 1
fi

echo "=== RELOAD APACHE ==="
apache2ctl -k graceful

echo ""
echo "=== PENNY CONFIGURATION COMPLETE ==="
echo "192.228.50.2  -> 301 -> http://www.K34.com/"
echo "penny.K34.com  -> 301 -> http://www.K34.com/"
