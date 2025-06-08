#!/bin/bash

# Redes objetivo
declare -A redes=(
  ["172.172.10"]="red_usuarios"
  ["172.172.20"]="red_servidores"
  ["172.172.30"]="red_dmz"
  ["172.172.40"]="red_admin"
  ["172.172.50"]="red_impresion"
)

# Enumerar interfaces con IPs
for interfaz in $(ip -o -4 addr show | awk '{print $2}' | sort -u); do
  ip=$(ip -o -4 addr show "$interfaz" | awk '{print $4}' | cut -d'/' -f1)
  if [[ -z "$ip" ]]; then continue; fi

  red="${ip%.*}" # elimina el último octeto

  if [[ ${redes["$red"]+_} ]]; then
    nuevo_nombre="${redes[$red]}"

    # Verificar si el nuevo nombre ya está en uso
    if ip link show "$nuevo_nombre" &>/dev/null; then
      echo "⚠️ El nombre $nuevo_nombre ya está en uso. Omitiendo $interfaz."
      continue
    fi

    echo "🔧 Renombrando $interfaz → $nuevo_nombre"
    ip link set "$interfaz" down
    ip link set "$interfaz" name "$nuevo_nombre"
    ip link set "$nuevo_nombre" up
  fi
done



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
iptables -A INPUT -i red_usuarios -j ACCEPT
iptables -A INPUT -i red_servidores -j ACCEPT
iptables -A INPUT -i red_dmz -j ACCEPT
iptables -A INPUT -i red_admin -j ACCEPT
iptables -A INPUT -i red_impresion -j ACCEPT

iptables -A FORWARD -i red_usuarios -o red_servidores -j ACCEPT
iptables -A FORWARD -i red_servidores -o red_usuarios -j ACCEPT
iptables -A FORWARD -i red_usuarios -o red_dmz -j ACCEPT
iptables -A FORWARD -i red_dmz -o red_usuarios -j ACCEPT
iptables -A FORWARD -i red_usuarios -o red_admin -j ACCEPT
iptables -A FORWARD -i red_admin -o red_usuarios -j ACCEPT
iptables -A FORWARD -i red_servidores -o red_dmz -j ACCEPT
iptables -A FORWARD -i red_dmz -o red_servidores -j ACCEPT
iptables -A FORWARD -i red_servidores -o red_admin -j ACCEPT
iptables -A FORWARD -i red_admin -o red_servidores -j ACCEPT
iptables -A FORWARD -i red_dmz -o red_admin -j ACCEPT
iptables -A FORWARD -i red_admin -o red_dmz -j ACCEPT

# Permitir tráfico establecido y relacionado
iptables -A FORWARD -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT


#Esta es una regla para loggear
iptables -I FORWARD -j LOG --log-prefix "FIREWALL-FORWARD: "