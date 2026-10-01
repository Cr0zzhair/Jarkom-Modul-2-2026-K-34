IP_OBLADI="192.228.10.6"
IP_DESMOND="192.228.10.7"
IP_OBLADA="192.228.10.5"
IP_MOLLY="192.228.10.4"

# Pastikan path ini sesuai dengan lokasi file zone K34.com milikmu
FILE_ZONE="/etc/bind/K34.com"

cat <<EOF >> $FILE_ZONE

; [Konfigurasi Soal Nomor 7]
vault   IN  A       $IP_OBLADI
vault   IN  A       $IP_DESMOND
core    IN  A       $IP_OBLADA
core    IN  A       $IP_MOLLY
www     IN  CNAME   penny
static  IN  CNAME   abbey
EOF

echo "Penambahan record selesai!"
