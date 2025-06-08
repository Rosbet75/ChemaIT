#!/bin/bash

# Nombre del archivo de log con timestamp
LOGFILE="/LOGS/firewall/tcpdump/tcpdump_capture_$(date +%Y%m%d_%H%M%S).log"

# Filtro para las subredes específicas
FILTER="net 172.172.10.0/24 or net 172.172.20.0/24 or net 172.172.30.0/24 or net 172.172.40.0/24"

echo "Iniciando captura de tráfico en redes internas por 30 segundos..."
echo "Log guardado en: $LOGFILE"

# Ejecutar tcpdump en segundo plano limitado a 30 segundos
timeout 30 tcpdump -i any $FILTER -nn -tttt > "$LOGFILE"

echo "Captura finalizada. Puedes revisar el archivo en: $LOGFILE"
