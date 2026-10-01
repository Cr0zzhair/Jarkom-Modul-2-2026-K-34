#!/bin/bash
# Script Verifikasi 3 Fase TTL DNS dengan Timestamp (Nomor 18)

DOMAIN="abbey.K34.com"
IP_LAMA="192.228.40.2"
IP_BARU="10.99.99.99"

echo "=========================================================="
echo "      VERIFIKASI 3 FASE TTL 15 DETIK ($DOMAIN)"
echo "=========================================================="

echo "-> [FASE 1] SEBELUM PERUBAHAN (Murni dari Server)"
CURRENT_TIME=$(date +"%H:%M:%S")
RESULT=$(dig +short $DOMAIN)
echo "[$CURRENT_TIME] Hasil query: $RESULT"
echo "----------------------------------------------------------"

echo "⚠️  INSTRUKSI DEMO:"
echo "1. Biarkan terminal ini terbuka."
echo "2. Pindah ke terminal PRAB, jalankan script ubah ke IP fiktif."
echo "3. Cepat kembali ke sini, lalu tekan [ENTER]!"
read -p "Tekan [ENTER] jika service di PRAB baru saja direstart..."

echo "----------------------------------------------------------"
echo "Memantau perubahan cache setiap 2 detik..."
echo "----------------------------------------------------------"

# Looping selama 24 detik (12 iterasi x 2 detik) untuk menangkap masa 15 detik
for ((i=1; i<=12; i++)); do
    CURRENT_TIME=$(date +"%H:%M:%S")
    RESULT=$(dig +short $DOMAIN)

    if [ "$RESULT" == "$IP_LAMA" ]; then
        echo "[$CURRENT_TIME] (Detik ke-$((i*2))) : $RESULT -> [FASE 2: Masih Cache]"
    elif [ "$RESULT" == "$IP_BARU" ]; then
        echo "[$CURRENT_TIME] (Detik ke-$((i*2))) : $RESULT -> [FASE 3: TTL Habis, IP Baru!]"
    else
        echo "[$CURRENT_TIME] (Detik ke-$((i*2))) : ${RESULT:-KOSONG} -> [Error/Timeout]"
    fi

    sleep 2
done

echo "=========================================================="
echo "Pengujian selesai! Silakan screenshot terminal ini untuk bukti."
