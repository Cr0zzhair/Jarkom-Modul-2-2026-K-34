#!/bin/bash
# ============================================================
# Script Reset: Kembalikan IP Abbey ke Normal (192.228.40.2)
# JALANKAN DI: PRAB (DNS Master)
# ============================================================
ZFILE="/etc/bind/K34.com"
NORMAL_IP="192.228.40.2"

echo "=========================================================="
echo "   MENGEMBALIKAN KOORDINAT ABBEY KE NORMAL ($NORMAL_IP)"
echo "=========================================================="

echo "[1/4] Menghapus record abbey fiktif..."
sed -i -E '/^abbey[[:space:]]/d' "$ZFILE"

echo "[2/4] Menuliskan kembali IP normal tanpa TTL 15..."
echo "abbey   IN  A   $NORMAL_IP" >> "$ZFILE"

echo "[3/4] Menaikkan Serial SOA agar tersinkron ke tedd..."
perl -0pi -e 's/(\bSOA\s+\S+\s+\S+\s*\(?(?:\s|;[^\n]*\n)*)(\d+)/$1.($2+1)/e' "$Z                                                                             FILE"

echo "[4/4] Merestart DNS service..."
service named restart
sleep 2

echo "=========================================================="
echo "Hasil pengecekan langsung ke server lokal (prab):"
dig +short abbey.K34.com @127.0.0.1
echo "=========================================================="
echo "Jika di atas muncul angka $NORMAL_IP, berarti sudah AMAN!"
echo "Sekarang kamu siap untuk reset pengujian 18 atau lanjut 20."
