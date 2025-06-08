#!/bin/bash
# Activa reenvío IP (ya lo hacemos en sysctl en command, aquí extra por si acaso)
echo 1 > /proc/sys/net/ipv4/ip_forward

# Limpia reglas previas
iptables -F
iptables -t nat -F
iptables -t mangle -F
iptables -X

# Política por defecto: bloquear todo
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT ACCEPT

# Permitir tráfico desde firewall mismo
iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT

# Permitir tráfico interno en cada interfaz del firewall
iptables -A INPUT -i eth0 -j ACCEPT
iptables -A INPUT -i eth1 -j ACCEPT
iptables -A INPUT -i eth2 -j ACCEPT
iptables -A INPUT -i eth3 -j ACCEPT

iptables -A FORWARD -i eth0 -o eth1 -j ACCEPT
iptables -A FORWARD -i eth1 -o eth0 -j ACCEPT
iptables -A FORWARD -i eth0 -o eth2 -j ACCEPT
iptables -A FORWARD -i eth2 -o eth0 -j ACCEPT
iptables -A FORWARD -i eth0 -o eth3 -j ACCEPT
iptables -A FORWARD -i eth3 -o eth0 -j ACCEPT
iptables -A FORWARD -i eth1 -o eth2 -j ACCEPT
iptables -A FORWARD -i eth2 -o eth1 -j ACCEPT
iptables -A FORWARD -i eth1 -o eth3 -j ACCEPT
iptables -A FORWARD -i eth3 -o eth1 -j ACCEPT
iptables -A FORWARD -i eth2 -o eth3 -j ACCEPT
iptables -A FORWARD -i eth3 -o eth2 -j ACCEPT

# Permitir tráfico establecido y relacionado
iptables -A FORWARD -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT


#Esta es una regla para loggear
iptables -I FORWARD -j LOG --log-prefix "FIREWALL-FORWARD: "