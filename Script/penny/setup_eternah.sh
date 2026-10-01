#!/bin/bash

echo "=========================================="
echo "       SETUP ETERNAL - PENNY"
echo "=========================================="

echo "[1] Update repository..."
apt update

if [ $? -ne 0 ]; then
    echo "ERROR: apt update gagal!"
    exit 1
fi

echo "[2] Memastikan PHP dan PHP-FPM tersedia..."
apt install -y php php-fpm

echo "[3] Mengecek versi PHP..."
php -v

echo "[4] Mengecek PHP-FPM..."
php-fpm8.4 -v

echo "[5] Menjalankan PHP-FPM..."
php-fpm8.4 -D 2>/dev/null || true

sleep 2

echo "[6] Mengecek socket PHP-FPM..."

if [ -S /run/php/php8.4-fpm.sock ]; then
    echo "PHP-FPM SOCKET OK"
    ls -l /run/php/php8.4-fpm.sock
else
    echo "ERROR: PHP-FPM socket tidak ditemukan!"
    ls -la /run/php/
    exit 1
fi

echo ""
echo "=========================================="
echo "       PHP-FPM SIAP"
echo "=========================================="
