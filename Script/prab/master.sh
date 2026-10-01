#!/bin/bash

# ==========================================
# DNS MASTER - PRAB
# Domain : K34.com
# ==========================================

DOMAIN="K34.com"

PRAB_IP="192.228.10.2"
TEDD_IP="192.228.10.3"
PENNY_IP="192.228.50.2"
FORWARDER="192.168.122.1"

echo "=========================================="
echo "      KONFIGURASI DNS MASTER - PRAB"
echo "=========================================="

# ------------------------------------------
# 1. Install BIND9
# ------------------------------------------
echo "[1] Install BIND9..."

apt-get update
apt-get install bind9 dnsutils -y


# ------------------------------------------
# 2. Konfigurasi named.conf.local
# ------------------------------------------
echo "[2] Membuat named.conf.local..."

cat > /etc/bind/named.conf.local <<EOF
zone "$DOMAIN" {
    type master;
    notify yes;
    also-notify { $TEDD_IP; };
    allow-transfer { $TEDD_IP; };
    file "/etc/bind/$DOMAIN";
};
EOF


# ------------------------------------------
# 3. Membuat Zone File
# ------------------------------------------
echo "[3] Membuat zone file..."

cat > /etc/bind/$DOMAIN <<EOF
\$TTL 604800

@       IN      SOA     prab.$DOMAIN. admin.$DOMAIN. (
                        1
                        604800
                        86400
                        2419200
                        604800 )

        IN      NS      prab.$DOMAIN.
        IN      NS      tedd.$DOMAIN.

prab    IN      A       $PRAB_IP
tedd    IN      A       $TEDD_IP

@       IN      A       $PENNY_IP
EOF


# ------------------------------------------
# 4. Konfigurasi Forwarder
# ------------------------------------------
echo "[4] Membuat named.conf.options..."

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


# ------------------------------------------
# 5. Cek konfigurasi
# ------------------------------------------
echo ""
echo "[5] Mengecek konfigurasi BIND..."

named-checkconf

if [ $? -ne 0 ]; then
    echo "ERROR: Konfigurasi BIND tidak valid!"
    exit 1
fi

echo "named-checkconf : OK"


# ------------------------------------------
# 6. Cek zone
# ------------------------------------------
echo ""
echo "[6] Mengecek zone $DOMAIN..."

named-checkzone "$DOMAIN" "/etc/bind/$DOMAIN"

if [ $? -ne 0 ]; then
    echo "ERROR: Zone tidak valid!"
    exit 1
fi

echo "Zone : OK"


# ------------------------------------------
# 7. Pastikan tidak ada named lama
# ------------------------------------------
echo ""
echo "[7] Mengecek proses named..."

if pgrep named > /dev/null; then
    echo "named sudah berjalan."
else
    echo "named belum berjalan."
    echo "Menjalankan named..."

    named -u bind
fi


# ------------------------------------------
# 8. Cek proses
# ------------------------------------------
echo ""
echo "[8] Status named..."

if pgrep named > /dev/null; then
    echo "named : RUNNING"
else
    echo "ERROR: named gagal berjalan!"
    exit 1
fi


# ------------------------------------------
# 9. Cek port 53
# ------------------------------------------
echo ""
echo "[9] Mengecek port DNS 53..."

ss -lnup | grep ':53'

echo ""
echo "=========================================="
echo "       DNS MASTER PRAB BERHASIL"
echo "=========================================="
echo "Domain    : $DOMAIN"
echo "Master    : $PRAB_IP"
echo "Slave     : $TEDD_IP"
echo "Penny     : $PENNY_IP"
echo "Forwarder : $FORWARDER"
echo "=========================================="
