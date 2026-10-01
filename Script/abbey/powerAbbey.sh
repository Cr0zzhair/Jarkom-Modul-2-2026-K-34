#!/bin/bash

# =========================
# INSTALL NGINX
# =========================
apt update
apt install nginx -y

# =========================
# AKTIFKAN REVERSE PROXY
# Abbey/Epsilon -> Oblada + Molly
# =========================
cat > /etc/nginx/sites-available/reverse-proxy <<'EOF'
upstream core_backend {
    server 192.228.10.5;
    server 192.228.10.4;
}

server {
    listen 80;
    server_name _;

    location / {
        proxy_pass http://core_backend;

        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
EOF

# =========================
# AKTIFKAN KONFIGURASI
# =========================
rm -f /etc/nginx/sites-enabled/default
ln -sf /etc/nginx/sites-available/reverse-proxy \
       /etc/nginx/sites-enabled/reverse-proxy

# =========================
# CEK KONFIGURASI
# =========================
nginx -t

# =========================
# JALANKAN NGINX
# =========================
nginx

# =========================
# VERIFIKASI PORT 80
# =========================
echo ""
echo "===== ABBEY / EPSILON REVERSE PROXY ====="
echo "Port 80:"
ss -lntp | grep :80

echo ""
echo "Nginx process:"
ps aux | grep nginx
