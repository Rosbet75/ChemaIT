#!/bin/bash
until ping -c1 172.172.10.1 &>/dev/null; do
  echo "Esperando firewall..."
  sleep 1
done

# Luego sigue con la ejecución normal
exec "$@"
