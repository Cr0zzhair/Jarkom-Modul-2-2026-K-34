#!/bin/bash
# Script Looping Testing TTL DNS dengan Penanganan Output

DOMAIN="abbey.K34.com"
TOTAL_CHECK=8
INTERVAL=3

echo "[INFO] Memulai pengujian perubahan TTL untuk $DOMAIN..."
echo "--------------------------------------------------------"

for ((i=1; i<=TOTAL_CHECK; i++))
do
    # Menjalankan perintah dig dan menangkap hasilnya
    RESULT=$(dig +short "$DOMAIN")

    # Error handling jika perintah dig gagal atau jaringan bermasalah
    if [ -z "$RESULT" ]; then
        echo "[WARNING] Percobaan ke-$i: Gagal mendapatkan respons dari DNS."
    else
        echo "[INFO] Percobaan ke-$i -> IP Terdeteksi: $RESULT"
    fi

    # Jeda waktu sebelum pengecekan berikutnya
    if [ $i -lt $TOTAL_CHECK ]; then
        sleep "$INTERVAL"
    fi
done

echo "--------------------------------------------------------"
echo "[SUKSES] Pengujian selesai! Perhatikan apakah IP berubah setelah 15 detik."
