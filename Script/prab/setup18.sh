#!/bin/bash
# ============================================================
# Script Auto-Setup Nomor 18 (Ubah IP Abbey & TTL 15 Detik)
# JALANKAN DI: PRAB (DNS Master)
# ============================================================
ZONE="K34.com"
ZFILE="/etc/bind/K34.com"
BACKUP="/root/K34.com.bak18.$(date +%s)"

echo "=========================================================="
echo "      MEMULAI SETUP NO 18: UBAH IP & TTL (15 Detik)"
echo "=========================================================="

echo "[1/5] Membackup konfigurasi zone -> $BACKUP"
cp -p "$ZFILE" "$BACKUP"

echo "[2/5] Mengubah record abbey menjadi IP fiktif (10.99.99.99)..."
# Hapus baris abbey lama agar tidak dobel
sed -i -E '/^abbey[[:space:]]/d' "$ZFILE"
# Tambahkan record abbey baru di baris paling bawah dengan TTL 15
echo "abbey 15 IN A 10.99.99.99" >> "$ZFILE"

echo "[3/5] Menaikkan nomor Serial SOA secara otomatis..."
# Menggunakan metode Perl yang terbukti ampuh dari No 19
perl -0pi -e 's/(\bSOA\s+\S+\s+\S+\s*\(?(?:\s|;[^\n]*\n)*)(\d+)/$1.($2+1)/e' "$Z                                                                             FILE"

echo "[4/5] Memvalidasi Zone File (named-checkzone)..."
if ! named-checkzone $ZONE "$ZFILE" > /dev/null 2>&1; then
    echo "[ERROR] Zone tidak valid! Mengembalikan file ke awal (rollback)..."
    cp -p "$BACKUP" "$ZFILE"
    exit 1
fi
echo "      -> Status OK! Syntax aman."

echo "[5/5] Merestart service DNS (mengirim update ke tedd)..."
service named restart
sleep 2

echo "=========================================================="
echo "[SUKSES] Konfigurasi di prab selesai dan DNS direstart!"
echo "Isi record abbey sekarang:"
grep "^abbey" "$ZFILE"
echo "=========================================================="
echo "⚡ SEKARANG CEPAT KEMBALI KE TERMINAL CLIENT (ALPHA)"
echo "⚡ LALU TEKAN [ENTER] PADA SCRIPT VERIFIKASI!"
echo "=========================================================="
