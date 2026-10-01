#!/bin/bash
# ============================================================
# Setup No 17 - TXT record untuk klien sayap kiri & kanan
# JALANKAN DI: PRAB (DNS Master)
#
# Kelebihan dibanding versi lama:
#  - Idempotent : dijalankan berapa kali pun, TXT tidak dobel
#  - Serial SOA : dinaikkan +1 otomatis, apa pun format zone file-nya
#                 (tidak bergantung komentar "; Serial")
#  - Aman       : backup dulu, validasi named-checkzone, rollback kalau gagal
#  - Bukti      : langsung menampilkan hasil query + status sinkron ke tedd
# ============================================================

ZONE="K34.com"
ZFILE="${ZFILE:-/etc/bind/K34.com}"
PRAB_IP="192.228.10.2"
TEDD_IP="192.228.10.3"
CLIENTS="alpha beta gamma delta epsilon"
BACKUP="/root/K34.com.bak17.$(date +%s)"

[ -f "$ZFILE" ] || { echo "ERROR: $ZFILE tidak ditemukan. Script ini dijalankan                                                                              di PRAB."; exit 1; }

echo "[1/6] Backup zone file -> $BACKUP"
cp -p "$ZFILE" "$BACKUP"
if ! PRECHECK=$(named-checkzone "$ZONE" "$BACKUP" 2>&1); then
  echo
  echo "ERROR: zone file ASLI sudah tidak valid SEBELUM script ini mengubah apa                                                                              pun:"
  echo "$PRECHECK"
  echo
  echo "Zone file tidak disentuh. Perbaiki error di atas dulu, lalu jalankan ula                                                                             ng."
  echo "(Jangan restart named dulu: zona K34.com bisa gagal dimuat.)"
  rm -f "$BACKUP"
  exit 1
fi
OLD=$(echo "$PRECHECK" | sed -n 's/.*loaded serial \([0-9]*\).*/\1/p')
echo "      serial sekarang: ${OLD:-?}"

echo "[2/6] Bersihkan TXT klien lama (kalau ada) supaya tidak dobel"
for h in $CLIENTS; do
  sed -i -E "/^${h}[[:space:]]+(IN[[:space:]]+)?TXT[[:space:]]/d" "$ZFILE"
done
sed -i -E '/^; \[.*Soal.*17/d' "$ZFILE"
# pastikan file diakhiri newline sebelum append
[ -n "$(tail -c1 "$ZFILE")" ] && echo >> "$ZFILE"

echo "[3/6] Tambahkan TXT record"
{
  echo "; [Soal 17 - TXT klien]"
  for h in $CLIENTS; do
    printf '%-8s IN TXT "%s"\n' "$h" "$h"
  done
} >> "$ZFILE"

echo "[4/6] Naikkan serial SOA (+1)"
# Mencari angka pertama setelah "SOA <mname> <rname> (" -> itulah serial.
# Jalan untuk SOA satu baris maupun multi-baris, dengan/tanpa komentar.
perl -0pi -e 's/(\bSOA\s+\S+\s+\S+\s*\(?(?:\s|;[^\n]*\n)*)(\d+)/$1.($2+1)/e or d                                                                             ie "SOA tidak ditemukan\n"' "$ZFILE" \
  || { echo "ERROR: gagal menaikkan serial. Rollback."; cp -p "$BACKUP" "$ZFILE"                                                                             ; exit 1; }

echo "[5/6] Validasi zone"
if ! CHECK=$(named-checkzone "$ZONE" "$ZFILE" 2>&1); then
  echo "$CHECK"
  echo "ERROR: zone tidak valid. Rollback ke backup."
  cp -p "$BACKUP" "$ZFILE"
  exit 1
fi
echo "$CHECK"
NEW=$(echo "$CHECK" | sed -n 's/.*loaded serial \([0-9]*\).*/\1/p')
echo "      serial: ${OLD:-?} -> $NEW"

echo "[6/6] Restart named (sekaligus kirim NOTIFY ke tedd)"
service named restart
sleep 3

echo
echo "================ HASIL ================"
echo "--- TXT dari prab (harus ada flag aa) ---"
dig TXT alpha.$ZONE @$PRAB_IP +noall +comments | grep -o "flags:[^;]*"
for h in $CLIENTS; do
  printf '%-18s -> %s\n' "$h.$ZONE" "$(dig +short TXT $h.$ZONE @$PRAB_IP)"
done
echo
echo "--- Sinkron ke tedd ---"
SP=$(dig +short SOA $ZONE @$PRAB_IP | awk '{print $3}')
ST=$(dig +short SOA $ZONE @$TEDD_IP +time=2 +tries=1 2>/dev/null | awk '{print $                                                                             3}')
echo "serial prab : ${SP:-?}"
echo "serial tedd : ${ST:-TIDAK MENJAWAB}"
if [ -n "$ST" ] && [ "$SP" = "$ST" ]; then
  echo "STATUS      : SINKRON"
else
  echo "STATUS      : BELUM SINKRON (cek tedd: service named running? lihat rest                                                                             ore_tedd.sh)"
fi
echo "======================================="
echo "Test dari client:  dig -t txt \$(hostname).$ZONE +short"
