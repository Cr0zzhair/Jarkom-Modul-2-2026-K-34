#!/bin/bash
# ============================================================
# Verifikasi No 19 (READ-ONLY) - JALANKAN DI: alpha (client)
# Membuktikan: outbound.K34.com -> CNAME -> http.badssl.com, dan isi
# halaman yang diambil lewat outbound.K34.com sama dengan aslinya.
# ============================================================
ZONE="K34.com"
NAME="outbound"
EXT="http.badssl.com"
FAIL=0
chk() { if [ "$1" = "1" ]; then echo "[PASS] $2"; else echo "[FAIL] $2"; FAIL=1; fi; }

echo "Node  : $(hostname)"
echo "Resolv: $(grep '^nameserver' /etc/resolv.conf | awk '{print $2}' | tr '\n' ' ')"
echo

echo "--- [1] DNS: dig $NAME.$ZONE ---"
OUT=$(dig $NAME.$ZONE +noall +answer +comments +time=5 +tries=1 2>&1)
echo "$OUT" | grep -E "status|flags|CNAME| A |error|no servers"
CN=$(dig +short CNAME $NAME.$ZONE +time=5 +tries=1 | head -1)
IP=$(dig +short A $NAME.$ZONE +time=5 +tries=1 | grep -E '^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$' | head -1)
echo

echo "--- [2] curl -H \"Host: $EXT\" http://$NAME.$ZONE ---"
BODY1=$(curl -s -m 15 -H "Host: $EXT" http://$NAME.$ZONE 2>&1)
echo "$BODY1" | head -20
echo

echo "--- [3] Pembanding: curl langsung http://$EXT ---"
BODY2=$(curl -s -m 15 http://$EXT 2>&1)
echo "(isi sama persis dengan di atas? lihat hasil di bawah)"
echo

SUM1=$(echo "$BODY1" | md5sum | cut -d' ' -f1); SUM2=$(echo "$BODY2" | md5sum | cut -d' ' -f1)
echo "======================================="
chk "$([ "$CN" = "${EXT}." ] && echo 1)" "CNAME $NAME.$ZONE -> ${CN:-(kosong)}"
chk "$([ -n "$IP" ] && echo 1)" "ter-resolve sampai IP: ${IP:-(tidak ada - cek rekursi/forwarder di prab)}"
chk "$([ -n "$BODY1" ] && echo "$BODY1" | grep -qi '<html' && echo 1)" "curl via $NAME.$ZONE mengembalikan HTML"
chk "$([ "$SUM1" = "$SUM2" ] && [ -n "$BODY1" ] && echo 1)" "isi sama dengan http://$EXT (md5 ${SUM1:0:8} vs ${SUM2:0:8})"
echo "======================================="
[ $FAIL -eq 0 ] && echo "HASIL NO 19: SEMUA PASS" || echo "HASIL NO 19: ADA YANG FAIL (lihat [FAIL] di atas)"
exit $FAIL
