#!/bin/bash
# Script Auto-Setup Web Dinamis (Nginx + PHP-FPM) untuk Nomor 10

echo "1. Menginstal Nginx dan PHP-FPM..."
apt-get update
apt-get install -y nginx php-fpm

echo "2. Memastikan layanan PHP 8.4 berjalan..."
service php8.4-fpm start

echo "3. Membuat halaman Beranda dan Profil (PHP)..."
# File index.php (Beranda)
cat <<'EOF' > /var/www/html/index.php
<?php
echo "<h1>Beranda Core K34</h1>";
echo "<p>Selamat datang di pusat layanan web dinamis (PHP-FPM) The Mesh!</p>";
?>
EOF

# File profil.php (Halaman Profil)
cat <<'EOF' > /var/www/html/profil.php
<?php
echo "<h1>Halaman Profil Agen</h1>";
echo "<p>Identitas tervalidasi. URL bersih tanpa akhiran php berhasil dieksekusi.</p>";
?>
EOF

# Bersihkan file default HTML bawaan Nginx agar tidak bentrok
rm -f /var/www/html/index.nginx-debian.html
rm -f /var/www/html/index.html

echo "4. Mengonfigurasi Nginx untuk Clean URL dan PHP-FPM..."
# Menggunakan 'EOF' dengan tanda kutip agar Nginx membaca variabel $uri secara utuh
cat <<'EOF' > /etc/nginx/sites-available/default
server {
    listen 80 default_server;
    root /var/www/html;

    # Prioritaskan pembacaan file PHP
    index index.php index.html;
    server_name _;

    # REWRITE RULE: Fitur URL Bersih untuk menyembunyikan akhiran .php
    location / {
        try_files $uri $uri/ $uri.php?$args;
    }

    # Pass eksekusi PHP ke PHP 8.4 Socket
    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/run/php/php8.4-fpm.sock;
    }
}
EOF

echo "5. Restart service Nginx..."
service nginx restart

echo "Selesai! Web dinamis siap didemokan."
