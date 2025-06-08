#!/bin/bash

# Esperar 30 segundos
sleep 30

# Crear archivo de log con marca de tiempo
LOGFILE="/LOGS/iptables/firewall_forward_$(date +%Y%m%d_%H%M%S).log"

# Ejecutar dmesg y guardar líneas que contengan "FIREWALL-FORWARD"
echo "[$(date)] Iniciando registro de mensajes FIREWALL-FORWARD en $LOGFILE"
dmesg | grep FIREWALL-FORWARD > "$LOGFILE"

echo "[$(date)] Registro completo."
