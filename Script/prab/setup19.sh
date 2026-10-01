#!/bin/bash
# ============================================================
# No 19 - CNAME outbound.K34.com -> http.badssl.com.
# JALANKAN DI: PRAB
#
# Beda dengan script lama:
#  - Serial SOA naik otomatis (versi lama mencari kata "Serial" yang tidak ada
#    di zone-mu, jadi serial tidak naik dan tedd tidak menarik record baru)
#  - Idempotent, validasi named-checkzone, backup, rollback otomatis
#  - Memeriksa sinkronisasi tedd dan apakah prab bisa menelusuri nama luar
# ============================================================

ZONE="K34.com"
ZFILE="${ZFILE:-/etc/bind/K34.com}"
PRAB_IP="${PRAB_IP:-192.228.10.2}"
TEDD_IP="${TEDD_IP:-192.228.10.3}"
NAME="outbound"
TARGET="http.badssl.com."
BACKUP="/root/K34.com.bak19.$(date +%s)"

die() { echo "ERROR: $*"; exit 1; }
srv_serial() { dig +short SOA "$ZONE" @"$1" +time=2 +tries=1 2>/dev/null | awk '                                                                             NF>=7 && $3 ~ /^[0-9]+$/ {print $3; exit}'; }
wait_serial() { local i s; for i in $(seq 1 "${3:-10}"); do s=$(srv_serial "$1")                                                                             ; [ "$s" = "$2" ] && return 0; sleep 1; done; return 1; }

[ -f "$ZFILE" ] || die "$ZFILE tidak ada. Script ini dijalankan di PRAB."
[ -n "$(srv_serial "$PRAB_IP")" ] || die "named di prab ($PRAB_IP) tidak menjawa                                                                             b. Jalankan: service named start"

echo "[1/6] Backup zone -> $BACKUP"
cp -p "$ZFILE" "$BACKUP"
if ! PRE=$(named-checkzone "$ZONE" "$BACKUP" 2>&1); then
  echo "$PRE"; rm -f "$BACKUP"
  die "zone file ASLI sudah tidak valid sebelum script mengubah apa pun. Perbaik                                                                             i dulu (zone tidak disentuh)."
fi
OLD=$(echo "$PRE" | sed -n 's/.*loaded serial \([0-9]*\).*/\1/p')
echo "      serial sekarang: $OLD"

echo "[2/6] Bersihkan record $NAME lama (kalau ada) supaya tidak dobel"
sed -i -E "/^${NAME}[[:space:]]/d" "$ZFILE"
sed -i -E '/^; \[.*Soal.*19/d' "$ZFILE"
[ -n "$(tail -c1 "$ZFILE")" ] && echo >> "$ZFILE"

echo "[3/6] Tambahkan CNAME"
{
  echo "; [Soal 19 - CNAME eksternal]"
  echo "$NAME IN CNAME $TARGET"
} >> "$ZFILE"

echo "[4/6] Naikkan serial SOA (+1) & validasi"
perl -0pi -e 's/(\bSOA\s+\S+\s+\S+\s*\(?(?:\s|;[^\n]*\n)*)(\d+)/$1.($2+1)/e or d                                                                             ie "SOA tidak ditemukan\n"' "$ZFILE" \
  || { cp -p "$BACKUP" "$ZFILE"; die "gagal menaikkan serial. Zone dikembalikan.                                                                             "; }
if ! CHECK=$(named-checkzone "$ZONE" "$ZFILE" 2>&1); then
  echo "$CHECK"; cp -p "$BACKUP" "$ZFILE"
  die "zone tidak valid. Zone dikembalikan ke backup ($BACKUP)."
fi
echo "$CHECK"
NEW=$(echo "$CHECK" | sed -n 's/.*loaded serial \([0-9]*\).*/\1/p')
echo "      serial: $OLD -> $NEW"

echo "[5/6] Reload named (sekaligus NOTIFY ke tedd)"
rndc reload >/dev/null 2>&1 || service named restart >/dev/null 2>&1
if ! wait_serial "$PRAB_IP" "$NEW" 6; then
  service named restart >/dev/null 2>&1
  wait_serial "$PRAB_IP" "$NEW" 8 || die "prab belum menjawab serial $NEW. Cek:                                                                              service named status (backup: $BACKUP)"
fi

echo "[6/6] Verifikasi"
FAILALL=0
chk() { if [ "$1" = "1" ]; then echo "[PASS] $2"; else echo "[FAIL] $2"; FAILALL                                                                             =1; fi; }
wait_serial "$TEDD_IP" "$NEW" 10; ST=$(srv_serial "$TEDD_IP"); SP=$(srv_serial "                                                                             $PRAB_IP")
CN_PRAB=$(dig +short CNAME $NAME.$ZONE @"$PRAB_IP" +time=2 +tries=1 | head -1)
CN_TEDD=$(dig +short CNAME $NAME.$ZONE @"$TEDD_IP" +time=2 +tries=1 | head -1)

echo
dig $NAME.$ZONE @"$PRAB_IP" +noall +answer +comments +time=5 +tries=1 | grep -E                                                                              "status|flags|CNAME| A "
echo
chk "$([ "$CN_PRAB" = "$TARGET" ] && echo 1)" "prab: $NAME.$ZONE CNAME -> ${CN_P                                                                             RAB:-(kosong)}"
chk "$([ "$CN_TEDD" = "$TARGET" ] && echo 1)" "tedd: $NAME.$ZONE CNAME -> ${CN_T                                                                             EDD:-(kosong)}"
chk "$([ -n "$SP" ] && [ "$SP" = "$ST" ] && [ "$SP" = "$NEW" ] && echo 1)" "seri                                                                             al prab = tedd = $NEW (prab:${SP:-?} tedd:${ST:-?})"

# Bonus (bergantung internet, bukan kesalahan script bila gagal):
IPS=$(dig +short A $NAME.$ZONE @"$PRAB_IP" +time=5 +tries=1 | grep -E '^[0-9]+\.                                                                             [0-9]+\.[0-9]+\.[0-9]+$' | tr '\n' ' ')
if [ -n "$IPS" ]; then
  echo "[INFO] prab berhasil menelusuri sampai IP: $IPS"
else
  echo "[WARN] prab belum bisa menelusuri nama luar (http.badssl.com). Cek inter                                                                             net prab & forwarder 192.168.122.1:"
  echo "       dig http.badssl.com @$PRAB_IP"
fi
echo "======================================="
[ $FAILALL -eq 0 ] && echo "HASIL NO 19 (sisi DNS): SEMUA PASS" || echo "HASIL N                                                                             O 19 (sisi DNS): ADA YANG FAIL"
echo "Uji dari client (alpha):  bash verify19.sh"
echo "======================================="
exit $FAILALL
