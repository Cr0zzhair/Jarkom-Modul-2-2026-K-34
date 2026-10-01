#!/bin/bash

# =========================
# BASIC AUTH /admin - PENNY
# =========================

apt update
apt install apache2-utils -y

# Aktifkan modul authentication
a2enmod auth_basic
a2enmod authn_file

# =========================
# BUAT USER
# =========================
htpasswd -cb /etc/apache2/.htpasswd prabs 'pakar_pinter_jadi_gob***'

# =========================
# BUAT HALAMAN /admin
# =========================
mkdir -p /var/www/admin

cat > /var/www/admin/index.html <<'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>Admin Area</title>
</head>
<body>
    <h1>Admin Area</h1>
    <p>Authenticated access granted.</p>
</body>
</html>
EOF

# =========================
# KONFIGURASI APACHE
# =========================
cat > /etc/apache2/sites-available/reverse-proxy.conf <<'EOF'
<VirtualHost *:80>

    ProxyPreserveHost On

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

    # Jangan teruskan /admin ke backend
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

    # Forward identitas client
    RequestHeader set X-Real-IP "%{REMOTE_ADDR}s"

</VirtualHost>
EOF

# =========================
# AKTIFKAN SITE & MODULE
# =========================
a2dissite 000-default.conf
a2ensite reverse-proxy.conf

a2enmod proxy
a2enmod proxy_http
a2enmod headers
a2enmod proxy_balancer
a2enmod lbmethod_byrequests

# =========================
# CEK KONFIGURASI
# =========================
apache2ctl configtest

# =========================
# JALANKAN / RELOAD APACHE
# =========================
apache2ctl -k graceful 2>/dev/null || apache2ctl start

# =========================
# VERIFIKASI
# =========================
echo ""
echo "===== BASIC AUTH /admin ====="
grep -A5 "/admin" /etc/apache2/sites-available/reverse-proxy.conf

echo ""
echo "===== APACHE PORT 80 ====="
ss -lntp | grep :80
