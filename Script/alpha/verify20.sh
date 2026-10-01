#!/bin/bash
# ==========================================
# Uji Coba Akhir (Tugas 20) - Sisi Klien
# ==========================================

TARGET="outbound.K34.com"
SERVER_DNS="192.228.10.2"

echo "[*] Memulai Verifikasi Akhir Klien..."
echo "--------------------------------------------------"

echo "1. Memeriksa rute resolusi DNS ke eksternal:"
# Menggunakan parameter +noall +answer agar outputnya rapi dan pro
dig $TARGET @$SERVER_DNS +noall +answer

echo ""
echo "2. Memeriksa konektivitas HTTP Header:"
# Mengambil baris pertama saja dari respon HTTP (contoh: HTTP/1.1 200 OK)
curl -s -I http://$TARGET | head -n 1

echo "--------------------------------------------------"
echo "[*] Verifikasi The Mesh Selesai."
