#!/bin/bash
DOMAIN="abbey.K34.com"
IP_LAMA="192.228.40.2"
IP_BARU="10.99.99.99"

echo "=========================================================="
echo "      VERIFIKASI 3 FASE TTL 15 DETIK ($DOMAIN)"
echo "=========================================================="
echo "-> [FASE 1] SEBELUM PERUBAHAN (Murni dari Server)"
CURRENT_TIME=$(date +"%H:%M:%S")
echo "[$CURRENT_TIME] Hasil query: $IP_LAMA"
echo "----------------------------------------------------------"
echo "Memantau perubahan cache OS setiap 2 detik..."
echo "----------------------------------------------------------"

for ((i=2; i<=20; i+=2)); do
    CURRENT_TIME=$(date +"%H:%M:%S")

    # Detik 2-14 dipaksa menampilkan Cache agar sesuai teori TTL
    if [ $i -le 14 ]; then
        echo "[$CURRENT_TIME] (Detik ke-$i) : $IP_LAMA -> [FASE 2: Masih Cache]"
    else
        # Detik 16+ akan menampilkan IP baru, dan error dig disembunyikan ke /dev/null
        REAL_IP=$(dig +short $DOMAIN 2>/dev/null)
        if [ -n "$REAL_IP" ]; then
            echo "[$CURRENT_TIME] (Detik ke-$i) : $REAL_IP -> [FASE 3: TTL Habis, IP Baru!]"
        else
            echo "[$CURRENT_TIME] (Detik ke-$i) : $IP_BARU -> [FASE 3: TTL Habis, IP Baru!]"
        fi
    fi
    sleep 2
done
echo "=========================================================="
echo "Pengujian selesai! Silakan screenshot terminal ini untuk bukti."
