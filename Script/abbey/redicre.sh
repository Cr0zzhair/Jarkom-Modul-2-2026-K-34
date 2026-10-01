#!/bin/bash

echo "=== BACKUP CONFIGURATION ==="

cp /etc/nginx/sites-available/reverse-proxy \
   /etc/nginx/sites-available/reverse-proxy.backup


echo "=== CONFIGURE ABBEY REDIRECT ==="

cat > /etc/nginx/sites-available/reverse-proxy <<'EOF'
upstream core_backend {
    server 192.228.10.5;
    server 192.228.10.4;
}

server {
    listen 80;
    listen [::]:80;

    server_name 192.228.40.2 abbey.K34.com;

    # REDIRECT KANONIK ABBEY
    return 302 http://static.K34.com/;
}
EOF


echo "=== CHECK NGINX CONFIGURATION ==="

nginx -t

if [ $? -ne 0 ]; then
    echo "ERROR: Nginx configuration invalid!"
    exit 1
fi


echo "=== RELOAD NGINX ==="

nginx -s reload

echo ""
echo "=== ABBEY REDIRECT CONFIGURATION COMPLETE ==="
echo "192.228.40.2 -> 302 -> http://static.K34.com/"
echo "abbey.K34.com -> 302 -> http://static.K34.com/"
