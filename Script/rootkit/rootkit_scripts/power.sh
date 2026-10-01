#!/bin/bash

echo "=== CONFIG ROOTKIT ==="

# ==========================================
# 1. CONFIGURE LAN INTERFACES
# ==========================================

ip addr flush dev eth1
ip addr flush dev eth2
ip addr flush dev eth3
ip addr flush dev eth4
ip addr flush dev eth5

ip addr add 192.228.10.1/24 dev eth1
ip addr add 192.228.20.1/24 dev eth2
ip addr add 192.228.30.1/24 dev eth3
ip addr add 192.228.40.1/24 dev eth4
ip addr add 192.228.50.1/24 dev eth5

ip link set eth1 up
ip link set eth2 up
ip link set eth3 up
ip link set eth4 up
ip link set eth5 up

# ==========================================
# 2. ENABLE IP FORWARDING
# ==========================================

sysctl -w net.ipv4.ip_forward=1

# ==========================================
# 3. NAT TO INTERNET
# ==========================================

iptables -t nat -A POSTROUTING \
    -s 192.228.0.0/16 \
    -o eth0 \
    -j MASQUERADE

# ==========================================
# 4. FORWARD LAN -> INTERNET
# ==========================================

iptables -A FORWARD -i eth1 -o eth0 -j ACCEPT
iptables -A FORWARD -i eth2 -o eth0 -j ACCEPT
iptables -A FORWARD -i eth3 -o eth0 -j ACCEPT
iptables -A FORWARD -i eth4 -o eth0 -j ACCEPT
iptables -A FORWARD -i eth5 -o eth0 -j ACCEPT

iptables -A FORWARD -i eth0 -m state \
    --state ESTABLISHED,RELATED -j ACCEPT

# ==========================================
# 5. INSTALL DHCP SERVER
# ==========================================

apt-get update
apt-get install -y isc-dhcp-server

# ==========================================
# 6. DHCP INTERFACES
# ==========================================

cat > /etc/default/isc-dhcp-server <<EOF
INTERFACESv4="eth1 eth2 eth3 eth4 eth5"
EOF

# ==========================================
# 7. DHCP CONFIGURATION
# ==========================================

cat > /etc/dhcp/dhcpd.conf <<EOF

authoritative;

default-lease-time 600;
max-lease-time 7200;

option domain-name-servers 8.8.8.8;

subnet 192.228.10.0 netmask 255.255.255.0 {
    range 192.228.10.100 192.228.10.200;
    option routers 192.228.10.1;
    option subnet-mask 255.255.255.0;
}

subnet 192.228.20.0 netmask 255.255.255.0 {
    range 192.228.20.100 192.228.20.200;
    option routers 192.228.20.1;
    option subnet-mask 255.255.255.0;
}

subnet 192.228.30.0 netmask 255.255.255.0 {
    range 192.228.30.100 192.228.30.200;
    option routers 192.228.30.1;
    option subnet-mask 255.255.255.0;
}

subnet 192.228.40.0 netmask 255.255.255.0 {
    range 192.228.40.100 192.228.40.200;
    option routers 192.228.40.1;
    option subnet-mask 255.255.255.0;
}

subnet 192.228.50.0 netmask 255.255.255.0 {
    range 192.228.50.100 192.228.50.200;
    option routers 192.228.50.1;
    option subnet-mask 255.255.255.0;
}

EOF

# ==========================================
# 8. CHECK DHCP CONFIG
# ==========================================

dhcpd -t -cf /etc/dhcp/dhcpd.conf

# ==========================================
# 9. START DHCP SERVER
# ==========================================

/etc/init.d/isc-dhcp-server restart

echo ""
echo "=== ROOTKIT CONFIG SELESAI ==="
echo ""

ip addr show eth1
ip addr show eth2
ip addr show eth3
ip addr show eth4
ip addr show eth5

echo ""
echo "IP FORWARDING:"
cat /proc/sys/net/ipv4/ip_forward

echo ""
echo "DHCP STATUS:"
/etc/init.d/isc-dhcp-server status
