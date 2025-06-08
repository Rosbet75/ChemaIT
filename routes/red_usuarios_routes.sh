#!/bin/bash
# Rutas para contenedores en red_usuarios

ip route add 172.172.20.0/24 via 172.172.10.2
ip route add 172.172.30.0/24 via 172.172.10.2
ip route add 172.172.40.0/24 via 172.172.10.2
