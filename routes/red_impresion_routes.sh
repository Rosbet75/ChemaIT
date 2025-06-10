#!/bin/bash
# Rutas para contenedores en red_servidores

# Rutas hacia otras redes via firewall
ip route add 172.172.10.0/24 via 172.172.50.2
ip route add 172.172.30.0/24 via 172.172.50.2
ip route add 172.172.40.0/24 via 172.172.50.2
ip route add 172.172.20.0/24 via 172.172.50.2