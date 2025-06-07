#!/bin/bash
# Rutas para contenedores en red_admin

ip route add 192.168.10.0/24 via 192.168.40.1
ip route add 192.168.20.0/24 via 192.168.40.1
ip route add 192.168.30.0/24 via 192.168.40.1
