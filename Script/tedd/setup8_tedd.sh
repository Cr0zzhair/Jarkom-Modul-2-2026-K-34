#!/bin/bash
# Script Setup Reverse Zone Nomor 8 untuk tedd (Slave)

echo "Menambahkan konfigurasi reverse zone (slave) ke named.conf.local..."
cat <<EOF >> /etc/bind/named.conf.local

zone "10.228.192.in-addr.arpa" {
    type slave;
    masters { 192.228.10.2; };
    file "/var/cache/bind/rev.10";
};
zone "40.228.192.in-addr.arpa" {
    type slave;
    masters { 192.228.10.2; };
    file "/var/cache/bind/rev.40";
};
zone "50.228.192.in-addr.arpa" {
    type slave;
    masters { 192.228.10.2; };
    file "/var/cache/bind/rev.50";
};
EOF

echo "Me-restart service DNS untuk menarik data..."
service named restart
echo "Selesai! Konfigurasi Slave berhasil."
