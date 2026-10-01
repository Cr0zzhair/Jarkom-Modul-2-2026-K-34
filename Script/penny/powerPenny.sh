#!/bin/bash

# =========================
# INSTALL APACHE
# =========================
apt update
apt install apache2 -y

# =========================
# AKTIFKAN MODUL REVERSE PROXY
# =========================
a2enmod proxy
a2enmod proxy_http
a2enmod headers
a2enmod proxy_balancer
a2enmod lbmethod_byrequests

# =========================
# KONFIGURASI REVERSE PROXY
# Penny -> Obladi + Desmond
# =========================
cat > /etc/apache2/sites-available/reverse-proxy.conf <<'EOF'
<VirtualHost *:80>

    ProxyPreserveHost On

    <Proxy "balancer://vault">
        BalancerMember http://192.228.10.6
        BalancerMember http://192.228.10.7
    </Proxy>

    ProxyPass        / balancer://vault/
    ProxyPassReverse / balancer://vault/

    RequestHeader set X-Real-IP "%{REMOTE_ADDR}s"

</VirtualHost>
EOF

# =========================
# AKTIFKAN SITE
# =========================
a2dissite 000-default.conf
a2ensite reverse-proxy.conf

# =========================
# CEK KONFIGURASI
# =========================
apache2ctl configtest

# =========================
# START APACHE
# =========================
apache2ctl start

# =========================
# VERIFIKASI
# =========================
echo ""
echo "===== PENNY REVERSE PROXY ====="
echo "Apache process:"
ps aux | grep apache2

echo ""
echo "Port 80:"
ss -lntp | grep :80
