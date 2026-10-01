#!/bin/bash

# ==========================================
# DNS SLAVE - TEDD
# Domain   : K34.com
# Master   : 192.228.10.2
# Slave    : 192.228.10.3
# ==========================================

DOMAIN="K34.com"
MASTER_IP="192.228.10.2"
FORWARDER="192.168.122.1"

echo "=========================================="
echo "       DNS SLAVE - TEDD"
echo "=========================================="

# 1. Install BIND9
echo "[1] Installing BIND9..."
apt-get update
apt-get install bind9 dnsutils -y

# 2. Pastikan direktori zone slave tersedia
echo "[2] Preparing zone directory..."
mkdir -p /var/cache/bind
chown bind:bind /var/cache/bind
chmod 755 /var/cache/bind

# 3. Konfigurasi named.conf.local
echo "[3] Configuring named.conf.local..."

cat > /etc/bind/named.conf.local <<EOF
zone "$DOMAIN" {
    type slave;
    masters { $MASTER_IP; };
    file "/var/cache/bind/$DOMAIN";
};
EOF

# 4. Konfigurasi forwarder
echo "[4] Configuring forwarder..."

cat > /etc/bind/named.conf.options <<EOF
options {
    directory "/var/cache/bind";

    forwarders {
        $FORWARDER;
    };

    recursion yes;

    listen-on { any; };
    listen-on-v6 { any; };

    allow-query { any; };
};
EOF

# 5. Cek konfigurasi
echo "[5] Checking BIND configuration..."

named-checkconf

if [ $? -ne 0 ]; then
    echo "ERROR: named-checkconf FAILED"
    exit 1
fi

echo "named-checkconf : OK"

# 6. Jalankan named
echo "[6] Starting named..."

if pgrep named > /dev/null; then
    echo "named is already running."
else
    named -u bind &
    sleep 3
fi

# 7. Cek proses
echo "[7] Checking named process..."

if pgrep named > /dev/null; then
    echo "named : RUNNING"
else
    echo "ERROR: named failed to start!"
    exit 1
fi

# 8. Cek port 53
echo "[8] Checking DNS port..."

ss -lnup | grep ':53'

# 9. Tunggu zone transfer
echo "[9] Waiting for zone transfer..."

sleep 3

if [ -f "/var/cache/bind/$DOMAIN" ]; then
    echo "Zone transfer : SUCCESS"
    ls -lh "/var/cache/bind/$DOMAIN"
else
    echo "Zone transfer : NOT YET AVAILABLE"
    echo "Check connection from TEDD to PRAB."
fi

echo ""
echo "=========================================="
echo "       DNS SLAVE TEDD CONFIGURED"
echo "=========================================="
echo "Domain    : $DOMAIN"
echo "Master    : $MASTER_IP"
echo "Forwarder : $FORWARDER"
echo "=========================================="
