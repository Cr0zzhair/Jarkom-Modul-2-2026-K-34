#!/bin/bash
# Script Otomasi Perbaikan Error DNS Slave (tedd)

FILE_CONF="/etc/bind/named.conf.local"

echo "[1/4] Mem-backup konfigurasi lama yang error..."
cp $FILE_CONF ${FILE_CONF}.rusak

echo "[2/4] Menulis ulang konfigurasi bersih (tanpa duplikat)..."
# Menggunakan '>' untuk menimpa (overwrite), BUKAN '>>' (append)
cat <<EOF > $FILE_CONF
// Zone Forward
zone "K34.com" {
    type slave;
    masters { 192.228.10.2; };
    file "/var/cache/bind/K34.com";
};

// Zone Reverse 10 (Vault & Core)
zone "10.228.192.in-addr.arpa" {
    type slave;
    masters { 192.228.10.2; };
    file "/var/cache/bind/rev.10";
};

// Zone Reverse 40 (Abbey)
zone "40.228.192.in-addr.arpa" {
    type slave;
    masters { 192.228.10.2; };
    file "/var/cache/bind/rev.40";
};

// Zone Reverse 50 (Penny)
zone "50.228.192.in-addr.arpa" {
    type slave;
    masters { 192.228.10.2; };
    file "/var/cache/bind/rev.50";
};
EOF

echo "[3/4] Mengecek validitas file konfigurasi (named-checkconf)..."
if named-checkconf; then
    echo "      -> Status OK! Tidak ada error syntax."
else
    echo "      -> GAGAL! Ada yang salah."
    exit 1
fi

echo "[4/4] Menyalakan service DNS (named)..."
service named restart

echo "=========================================================="
echo "[SUKSES] Node tedd sudah sehat kembali dan service menyala!"
echo "Sekarang silakan lanjut ke node PRAB."
echo "=========================================================="
