#!/bin/bash
# ============================================================
# Verifikasi No 17 - TXT record klien (READ-ONLY, tidak mengubah apa pun)
# JALANKAN DI: alpha (untuk screenshot rangkuman), lalu di beta/gamma/delta/epsilon
#              (opsional: di prab/tedd juga boleh)
# ============================================================

ZONE="K34.com"
PRAB="192.228.10.2"
TEDD="192.228.10.3"
CLIENTS="alpha beta gamma delta epsilon"
ME=$(hostname)
FAIL=0

# nama yang dipakai untuk tes per-host (kalau dijalankan di bukan klien, pakai alpha)
T="$ME"
case " $CLIENTS " in *" $ME "*) ;; *) T="alpha" ;; esac

q() { dig +short +time=2 +tries=1 TXT "$1.$ZONE" $2 2>/dev/null | head -1; }

echo "Node  : $ME"
echo "Resolv: $(grep '^nameserver' /etc/resolv.conf | awk '{print $2}' | tr '\n' ' ')"
echo

echo "--- [1] TXT kelima klien (resolver default) ---"
for h in $CLIENTS; do
  got=$(q "$h")
  if [ "$got" = "\"$h\"" ]; then st="PASS"; else st="FAIL"; FAIL=1; fi
  printf '%-18s -> %-12s [%s]\n' "$h.$ZONE" "${got:-(kosong)}" "$st"
done
echo

echo "--- [2] Perintah soal: dig -t txt $T.$ZONE +short ---"
dig -t txt $T.$ZONE +short
echo

echo "--- [3] Dijawab langsung per server ($T.$ZONE) ---"
for pair in "prab:$PRAB" "tedd:$TEDD"; do
  name=${pair%%:*}; ip=${pair##*:}
  got=$(q "$T" "@$ip")
  if [ "$got" = "\"$T\"" ]; then st="PASS"
  elif [ -z "$got" ]; then st="TIDAK MENJAWAB"; [ "$name" = "prab" ] && FAIL=1
  else st="FAIL"; FAIL=1; fi
  printf '%-5s (%s) -> %-12s [%s]\n' "$name" "$ip" "${got:-(kosong)}" "$st"
done
echo

echo "--- [4] Server yang menjawab & flag ---"
dig TXT $T.$ZONE 2>/dev/null | grep -E "flags:|SERVER:" | sed 's/^;; //'
echo

echo "======================================="
if [ $FAIL -eq 0 ]; then
  echo "HASIL NO 17: SEMUA PASS"
else
  echo "HASIL NO 17: ADA YANG FAIL (lihat baris [FAIL]/[kosong] di atas)"
fi
echo "(tedd hanya info tambahan; wajib PASS: resolver default & prab)"
echo "======================================="
exit $FAIL
