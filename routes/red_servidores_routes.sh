#!/bin/bash
# Rutas para contenedores en red_servidores

# Rutas hacia otras redes via firewall
ip route add 192.168.10.0/24 via 192.168.20.1
ip route add 192.168.30.0/24 via 192.168.20.1
ip route add 192.168.40.0/24 via 192.168.20.1
