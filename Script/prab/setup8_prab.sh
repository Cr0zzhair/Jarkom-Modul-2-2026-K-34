#!/bin/bash
# Script Setup Reverse Zone Nomor 8 untuk prab (Master)

echo "Menambahkan konfigurasi reverse zone ke named.conf.local..."
cat <<EOF >> /etc/bind/named.conf.local

// Reverse zone untuk area vault & core (192.228.10.x)
zone "10.228.192.in-addr.arpa" {
    type master;
    file "/etc/bind/rev.10";
    allow-transfer { 192.228.10.3; };
};
// Reverse zone untuk abbey (192.228.40.x)
zone "40.228.192.in-addr.arpa" {
    type master;
    file "/etc/bind/rev.40";
    allow-transfer { 192.228.10.3; };
};
// Reverse zone untuk penny (192.228.50.x)
zone "50.228.192.in-addr.arpa" {
    type master;
    file "/etc/bind/rev.50";
    allow-transfer { 192.228.10.3; };
};
EOF

echo "Membuat file zona rev.10..."
cat <<EOF > /etc/bind/rev.10
\$TTL 604800
@ IN SOA prab.K34.com. admin.K34.com. ( 1 604800 86400 2419200 604800 )
@ IN NS prab.K34.com.
@ IN NS tedd.K34.com.
4 IN PTR core.K34.com.
5 IN PTR core.K34.com.
6 IN PTR vault.K34.com.
7 IN PTR vault.K34.com.
EOF

echo "Membuat file zona rev.40..."
cat <<EOF > /etc/bind/rev.40
\$TTL 604800
@ IN SOA prab.K34.com. admin.K34.com. ( 1 604800 86400 2419200 604800 )
@ IN NS prab.K34.com.
@ IN NS tedd.K34.com.
2 IN PTR abbey.K34.com.
EOF

echo "Membuat file zona rev.50..."
cat <<EOF > /etc/bind/rev.50
\$TTL 604800
@ IN SOA prab.K34.com. admin.K34.com. ( 1 604800 86400 2419200 604800 )
@ IN NS prab.K34.com.
@ IN NS tedd.K34.com.
2 IN PTR penny.K34.com.
EOF

echo "Me-restart service DNS..."
service named restart
echo "Selesai! Konfigurasi Master berhasil."
