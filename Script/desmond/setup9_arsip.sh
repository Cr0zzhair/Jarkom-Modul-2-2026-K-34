#!/bin/bash

# 1. Update dan install apache2
apt-get update
apt-get install -y apache2

# 2. Buat folder /arsip dan isi beberapa file dummy buat dites nanti
mkdir -p /arsip
echo "Dokumen Rahasia 1" > /arsip/rahasia1.txt
echo "Laporan Keuangan" > /arsip/laporan.pdf
echo "Catatan Penting" > /arsip/catatan.txt

# 3. Tambahkan konfigurasi Alias dan Autoindex ke Apache
cat <<EOF > /etc/apache2/conf-available/arsip.conf
Alias /arsip /arsip/
<Directory /arsip/>
    Options Indexes FollowSymLinks
    AllowOverride None
    Require all granted
</Directory>
EOF

# 4. Aktifkan konfigurasi arsip dan restart apache
a2enconf arsip
service apache2 restart
