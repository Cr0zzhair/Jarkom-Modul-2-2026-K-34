#!/bin/bash

apt update
apt install apache2 -y

echo "Desmond Backend" > /var/www/html/index.html

apache2ctl configtest
apache2ctl start

echo "=== DESMOND BACKEND ==="
echo "IP:"
hostname -I
echo "Apache:"
ps aux | grep apache2
echo "Port 80:"
ss -lntp | grep :80
