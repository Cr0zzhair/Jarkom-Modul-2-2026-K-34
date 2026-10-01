#!/bin/bash

cat > /etc/bind/K34.com <<'EOF'
$TTL 604800
@       IN      SOA     prab.K34.com. admin.K34.com. (
                        3
                        604800
                        86400
                        2419200
                        604800 )

        IN      NS      prab.K34.com.
        IN      NS      tedd.K34.com.

prab    IN      A       192.228.10.2
tedd    IN      A       192.228.10.3

rootkit IN      A       192.228.10.1
alpha   IN      A       192.228.20.2
beta    IN      A       192.228.20.3
gamma   IN      A       192.228.20.4
delta   IN      A       192.228.30.2
epsilon IN      A       192.228.30.3
abbey   IN      A       192.228.40.2
penny   IN      A       192.228.50.2
obladi  IN      A       192.228.10.6
desmond IN      A       192.228.10.7
oblada  IN      A       192.228.10.5
molly   IN      A       192.228.10.4

@       IN      A       192.228.50.2
www     IN      A       192.228.50.2
static  IN      A       192.228.40.2
EOF

echo "=== CHECK ZONE ==="
named-checkzone K34.com /etc/bind/K34.com

echo ""
echo "=== RELOAD DNS ==="
rndc reload K34.com

echo ""
echo "=== DONE ==="
