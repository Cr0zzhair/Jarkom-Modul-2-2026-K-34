#!/bin/bash
# Script Otomatis Ubah IP Abbey dan Naikkan Serial SOA dengan Error Handling

FILE_ZONE="/etc/bind/K34.com"

# Cek apakah file zona ada
if [ ! -f "$FILE_ZONE" ]; then
    echo "[ERROR] File zona $FILE_ZONE tidak ditemukan!" >&2
    exit 1
fi

echo "[INFO] Mengubah konfigurasi abbey ke IP fiktif (TTL 15 detik)..."
# Ganti baris abbey dengan TTL 15 dan IP fiktif
sed -i '/abbey/c\abbey          15      IN      A       10.99.99.99' "$FILE_ZONE                                                                             "
if [ $? -ne 0 ]; then
    echo "[ERROR] Gagal mengubah baris konfigurasi abbey pada file zona!" >&2
    exit 1
fi

echo "[INFO] Menaikkan nomor Serial SOA secara otomatis..."
awk '{
    if ($0 ~ /Serial/) {
        sub($1, $1+1)
    }
    print
}' "$FILE_ZONE" > temp_zone && mv temp_zone "$FILE_ZONE"
if [ $? -ne 0 ]; then
    echo "[ERROR] Gagal menaikkan Serial SOA!" >&2
    exit 1
fi

echo "[INFO] Melakukan restart service DNS (named)..."
service named restart
if [ $? -ne 0 ]; then
    echo "[ERROR] Gagal merestart service named! Cek konfigurasi zona dengan 'na                                                                             med-checkzone'." >&2
    exit 1
fi

echo "[SUKSES] Konfigurasi server berhasil diperbarui dan DNS direstart!"
