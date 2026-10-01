#!/bin/bash
# ============================================================
# No 18 - Ubah A record abbey ke IP fiktif + TTL 15 detik + serial naik + sinkro                                                                             n tedd
#         + verifikasi 3 fase (sebelum / saat TTL belum habis / setelah TTL habi                                                                             s)
#
# JALANKAN DI: PRAB
#   bash run18.sh            -> kerjakan no 18 + uji 3 fase otomatis (+/- 30 det                                                                             ik)
#   bash run18.sh restore    -> kembalikan IP abbey ke semula (setelah screensho                                                                             t selesai)
#
# KENAPA ADA "CACHE" SENDIRI?
#   prab/tedd adalah server authoritative: tidak punya cache, jawabannya selalu                                                                              terbaru.
#   Supaya "masih IP lama karena cache" bisa dibuktikan, query dilewatkan ke res                                                                             olver
#   caching sementara (named instance kedua, 127.0.0.1:5353) yang meneruskan K34                                                                             .com
#   ke prab. Resolver ini dimatikan otomatis saat script selesai.
#
# URUTAN PENTING: TTL 15 dipasang LEBIH DULU (IP masih lama), baru IP diganti.
#   Kalau TTL dan IP diubah bersamaan, cache lama masih memegang TTL lama (60480                                                                             0).
# ============================================================

ZONE="K34.com"
ZFILE="${ZFILE:-/etc/bind/K34.com}"
PRAB_IP="${PRAB_IP:-192.228.10.2}"
TEDD_IP="${TEDD_IP:-192.228.10.3}"
NAME="abbey"
TTL=15
ORIG_FILE="/root/abbey_ip_asli.txt"
CDIR="/var/cache/bind18"
CCONF="$CDIR/named18.conf"
CPORT=5353
MODE="${1:-run}"

ABBEY_SED='^abbey[[:space:]]+(([0-9]+)[[:space:]]+)?IN[[:space:]]+A[[:space:]]+(                                                                             [0-9.]+).*$'

die()  { echo "ERROR: $*"; exit 1; }
hr()   { echo "------------------------------------------------------------"; }

[ "$(id -u)" = "0" ] || die "jalankan sebagai root."
[ -f "$ZFILE" ]      || die "$ZFILE tidak ada. Script ini dijalankan di PRAB."

# ---------- fungsi bantu ----------
get_ip()     { sed -nE "s/${ABBEY_SED}/\3/p" "$ZFILE"; }
zone_serial(){ named-checkzone "$ZONE" "$ZFILE" 2>&1 | sed -n 's/.*loaded serial                                                                              \([0-9]*\).*/\1/p'; }
srv_serial() { dig +short SOA "$ZONE" @"$1" +time=2 +tries=1 2>/dev/null | awk '                                                                             NF>=7 && $3 ~ /^[0-9]+$/ {print $3; exit}'; }
ip_of()      { awk '$4=="A"{print $5; exit}'; }
ttl_of()     { awk '$4=="A"{print $2; exit}'; }
q_cache()    { dig @127.0.0.1 -p $CPORT $NAME.$ZONE +noall +answer +time=3 +trie                                                                             s=1 2>/dev/null; }
q_srv()      { dig @"$1" $NAME.$ZONE +noall +answer +time=3 +tries=1 2>/dev/null                                                                             ; }

wait_serial() {   # $1=server $2=serial $3=maks detik
  local i s
  for i in $(seq 1 "${3:-10}"); do
    s=$(srv_serial "$1"); [ "$s" = "$2" ] && return 0; sleep 1
  done
  return 1
}

reload_named() {
  rndc reload >/dev/null 2>&1 || service named restart >/dev/null 2>&1
}

# Ubah record abbey -> "abbey 15 IN A <ip>", naikkan serial, validasi, reload.
apply_zone_change() {   # $1 = IP untuk abbey
  local ip="$1" bk="/root/K34.com.bak18.$(date +%s)"
  cp -p "$ZFILE" "$bk"
  sed -i -E "s/${ABBEY_SED}/abbey ${TTL} IN A ${ip}/" "$ZFILE"
  perl -0pi -e 's/(\bSOA\s+\S+\s+\S+\s*\(?(?:\s|;[^\n]*\n)*)(\d+)/$1.($2+1)/e or                                                                              die "SOA tidak ditemukan\n"' "$ZFILE" \
    || { cp -p "$bk" "$ZFILE"; die "gagal menaikkan serial (zone dikembalikan)."                                                                             ; }
  if ! CHECK=$(named-checkzone "$ZONE" "$ZFILE" 2>&1); then
    echo "$CHECK"; cp -p "$bk" "$ZFILE"; die "zone tidak valid (zone dikembalika                                                                             n ke backup $bk)."
  fi
  NEW_SERIAL=$(echo "$CHECK" | sed -n 's/.*loaded serial \([0-9]*\).*/\1/p')
  reload_named
  if ! wait_serial "$PRAB_IP" "$NEW_SERIAL" 6; then
    service named restart >/dev/null 2>&1
    wait_serial "$PRAB_IP" "$NEW_SERIAL" 8 || die "prab belum menjawab serial $N                                                                             EW_SERIAL. Zone file sudah diubah (backup: $bk). Cek: service named status"
  fi
}

stop_cache() {
  [ -f "$CDIR/named18.pid" ] && kill "$(cat "$CDIR/named18.pid")" 2>/dev/null
  pkill -f "named -c $CCONF" 2>/dev/null
  sleep 1
}

start_cache() {
  stop_cache
  rm -rf "$CDIR"; mkdir -p "$CDIR"; chown bind:bind "$CDIR" 2>/dev/null
  cat > "$CCONF" <<EOF
options {
    directory "$CDIR";
    pid-file "$CDIR/named18.pid";
    listen-on port $CPORT { 127.0.0.1; };
    listen-on-v6 { none; };
    allow-query { 127.0.0.1; };
    recursion yes;
    allow-recursion { 127.0.0.1; };
    dnssec-validation no;
};
controls { };
zone "$ZONE" {
    type forward;
    forward only;
    forwarders { $PRAB_IP port 53; };
};
EOF
  chown bind:bind "$CCONF" 2>/dev/null
  named-checkconf "$CCONF" || return 1
  named -c "$CCONF" -u bind || return 1
  local i
  for i in 1 2 3 4 5 6; do
    dig +short +time=1 +tries=1 @127.0.0.1 -p $CPORT version.bind chaos txt >/de                                                                             v/null 2>&1 && return 0
    sleep 1
  done
  return 1
}

# ============================================================
# MODE: restore
# ============================================================
if [ "$MODE" = "restore" ]; then
  [ -f "$ORIG_FILE" ] || die "$ORIG_FILE tidak ada (belum pernah menjalankan run                                                                             18.sh?)."
  ORIG=$(cat "$ORIG_FILE")
  echo "Mengembalikan A record $NAME.$ZONE ke $ORIG (TTL tetap $TTL detik)"
  apply_zone_change "$ORIG"
  wait_serial "$TEDD_IP" "$NEW_SERIAL" 10 && echo "tedd sinkron (serial $NEW_SER                                                                             IAL)" || echo "WARNING: tedd belum sinkron"
  echo "--- prab ---"; q_srv "$PRAB_IP"
  echo "--- tedd ---"; q_srv "$TEDD_IP"
  exit 0
fi

# ============================================================
# MODE: run
# ============================================================
echo "[0/6] Pra-pemeriksaan"
PRE=$(named-checkzone "$ZONE" "$ZFILE" 2>&1) || { echo "$PRE"; die "zone file su                                                                             dah tidak valid sebelum script mengubah apa pun. Perbaiki dulu."; }
[ "$(grep -cE "$ABBEY_SED" "$ZFILE")" = "1" ] || die "harus ada TEPAT 1 A record                                                                              '$NAME' di $ZFILE (ditemukan: $(grep -cE "$ABBEY_SED" "$ZFILE"))."
[ -n "$(srv_serial "$PRAB_IP")" ]  || die "named di prab ($PRAB_IP) tidak menjaw                                                                             ab. Jalankan: service named start"
OLD_IP=$(get_ip)
[ -f "$ORIG_FILE" ] || echo "$OLD_IP" > "$ORIG_FILE"
echo "      IP abbey sekarang : $OLD_IP"
echo "      IP asli (disimpan): $(cat "$ORIG_FILE")"

echo "[1/6] Pasang TTL ${TTL} detik pada record abbey (IP MASIH LAMA) + naikkan                                                                              serial"
apply_zone_change "$OLD_IP"
S1=$NEW_SERIAL
echo "      serial: -> $S1"
wait_serial "$TEDD_IP" "$S1" 10 && echo "      tedd sudah sinkron (serial $S1)"                                                                              || echo "      WARNING: tedd belum sinkron"

echo "[2/6] Nyalakan resolver caching sementara (127.0.0.1:$CPORT -> prab)"
start_cache || die "resolver caching gagal start. Cek: named-checkconf $CCONF ;                                                                              named -g -c $CCONF"
trap stop_cache EXIT

echo
hr; echo "FASE 1 - SEBELUM PERUBAHAN (harus IP lama)"; hr
T0=$(date +%s)
P1_CACHE=$(q_cache); P1_PRAB=$(q_srv "$PRAB_IP")
echo "via cache : $P1_CACHE"
echo "langsung prab : $P1_PRAB"

echo
echo "[3/6] Ubah A record abbey ke IP fiktif + naikkan serial"
NEW_IP="10.99.$((RANDOM % 254 + 1)).$((RANDOM % 254 + 1))"
apply_zone_change "$NEW_IP"
S2=$NEW_SERIAL
ELAPSED=$(( $(date +%s) - T0 ))
# jeda singkat supaya TTL di cache terlihat MENURUN (bukti jawaban berasal dari                                                                              cache)
if [ "$ELAPSED" -lt 4 ]; then sleep $((4 - ELAPSED)); ELAPSED=4; fi

echo
hr; echo "FASE 2 - SAAT PERUBAHAN BARU TERJADI, JEDA ${TTL} DETIK (cache masih I                                                                             P lama)"; hr
P2_CACHE=$(q_cache); P2_PRAB=$(q_srv "$PRAB_IP")
echo "via cache : $P2_CACHE"
echo "langsung prab : $P2_PRAB   <- prab sudah IP baru, tapi cache belum tahu"
echo "(waktu sejak fase 1: ${ELAPSED} detik, TTL cache ${TTL} detik)"
[ "$ELAPSED" -ge $((TTL - 1)) ] && echo "WARNING: terlalu lambat, cache mungkin                                                                              sudah kedaluwarsa. Jalankan ulang script."

echo
echo "[4/6] Cek sinkronisasi tedd (serial harus sama)"
wait_serial "$TEDD_IP" "$S2" 10; TEDD_OK=$?
SP=$(srv_serial "$PRAB_IP"); ST=$(srv_serial "$TEDD_IP")
echo "serial prab : $SP"
echo "serial tedd : ${ST:-TIDAK MENJAWAB}"
P_TEDD=$(q_srv "$TEDD_IP"); echo "tedd menjawab: ${P_TEDD:-(kosong)}"

echo
echo "[5/6] Menunggu TTL cache habis..."
NOW=$(date +%s); WAIT=$(( T0 + TTL + 2 - NOW )); [ "$WAIT" -gt 0 ] && sleep "$WA                                                                             IT"

echo
hr; echo "FASE 3 - SETELAH TTL HABIS (harus IP fiktif baru)"; hr
P3_CACHE=$(q_cache)
echo "via cache : $P3_CACHE"

# ---------- ringkasan ----------
chk() { if [ "$1" = "1" ]; then echo "[PASS] $2"; else echo "[FAIL] $2"; FAILALL                                                                             =1; fi; }
FAILALL=0
echo
echo "[6/6] RINGKASAN"; hr
chk "$([ "$(echo "$P1_CACHE" | ip_of)" = "$OLD_IP" ] && echo 1)" "Fase 1: IP lam                                                                             a ($OLD_IP) sebelum perubahan"
chk "$([ "$(echo "$P2_CACHE" | ip_of)" = "$OLD_IP" ] && [ "$(echo "$P2_PRAB" | i                                                                             p_of)" = "$NEW_IP" ] && echo 1)" "Fase 2: cache masih IP lama, prab sudah IP bar                                                                             u ($NEW_IP)"
chk "$([ "$(echo "$P3_CACHE" | ip_of)" = "$NEW_IP" ] && echo 1)" "Fase 3: setela                                                                             h TTL habis berubah ke IP fiktif ($NEW_IP)"
chk "$([ "$(echo "$P2_PRAB" | ttl_of)" = "$TTL" ] && echo 1)" "TTL record abbey                                                                              = $TTL detik"
chk "$([ -n "$SP" ] && [ "$SP" = "$ST" ] && [ "$SP" = "$S2" ] && echo 1)" "Seria                                                                             l SOA naik ($S1 -> $S2) dan sama di prab & tedd"
chk "$([ "$(echo "$P_TEDD" | ip_of)" = "$NEW_IP" ] && echo 1)" "tedd menjawab IP                                                                              baru"
hr
if [ "$FAILALL" = "0" ]; then echo "HASIL NO 18: SEMUA PASS"; else echo "HASIL N                                                                             O 18: ADA YANG FAIL (lihat di atas)"; fi
echo
echo "CATATAN: abbey.$ZONE sekarang menunjuk ke IP fiktif. static.$ZONE (CNAME k                                                                             e abbey) ikut berubah."
echo "         Setelah screenshot selesai, kembalikan dengan:  bash run18.sh res                                                                             tore"
exit $FAILALL
