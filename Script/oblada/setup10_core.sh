#!/bin/bash
# Script Setup Web Dinamis (Nginx + PHP-FPM) di Node Core

echo "1. Install Nginx dan PHP-FPM..."
apt-get update
apt-get install -y nginx php-fpm

# Mencari lokasi socket PHP-FPM yang terinstal otomatis (karena versi PHP bisa beda-beda)
PHP_SOCK=$(find /run/php /var/run/php -name "*.sock" 2>/dev/null | head -n 1)

echo "2. Membuat halaman Beranda dan Profil (PHP)..."
# File index.php (Beranda)
cat <<EOF > /var/www/html/index.php
<?php
echo "<h1>Beranda Core K34</h1>";
echo "<p>Selamat datang di pusat layanan web dinamis (PHP-FPM) The Mesh!</p>";
?>
EOF

# File profil.php (Halaman Profil)
cat <<EOF > /var/www/html/profil.php
<?php
echo "<h1>Halaman Profil Agen</h1>";
echo "<p>Identitas tervalidasi. URL bersih tanpa akhiran php berhasil dieksekusi.</p>";
?>
EOF

# Bersihkan file index bawaan HTML biar nggak bentrok
rm -f /var/www/html/index.nginx-debian.html
rm -f /var/www/html/index.html

echo "3. Mengonfigurasi Nginx dengan fitur Clean URL / Rewrite..."
cat <<EOF > /etc/nginx/sites-available/default
server {
    listen 80 default_server;
    root /var/www/html;

    # Prioritaskan pembacaan index.php
    index index.php index.html;
    server_name _;

    # REWRITE RULE: Fitur URL Bersih (Mencari file .php otomatis)
    location / {
        try_files \$uri \$uri/ \$uri.php?\$args;
    }

    # Pass eksekusi PHP ke PHP-FPM Socket
    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:\$PHP_SOCK;
    }
}
EOF

echo "4. Restart Service..."
service nginx restart
# Restart service PHP (nama service menyesuaikan versi yang terinstall)
PHP_SVC=$(ls /etc/init.d/ | grep php | grep fpm)
service \$PHP_SVC restart

echo "Setup selesai! Web dinamis siap diuji."
