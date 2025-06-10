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

# Activa reenvío IP
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

# Permitir tráfico establecido y relacionado (debe ir al principio)
iptables -A FORWARD -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

# Regla de logging (colocada temprano para capturar más tráfico)
iptables -I FORWARD -j LOG --log-prefix "FIREWALL-FORWARD: "

# ================= REGLAS ESPECÍFICAS =================

# ----- Reglas para red_admin -----
iptables -A FORWARD -i red_admin -o red_dmz -j ACCEPT
iptables -A FORWARD -i red_admin -o red_servidores -j ACCEPT
iptables -A FORWARD -i red_admin -o red_usuarios -j ACCEPT

# SSH desde hosts específicos de admin
iptables -A FORWARD -i red_admin -s 172.172.40.20 -p tcp --dport 22 -j ACCEPT
iptables -A FORWARD -i red_admin -s 172.172.40.21 -p tcp --dport 22 -j ACCEPT
iptables -A FORWARD -i red_admin -s 172.172.40.22 -p tcp --dport 22 -j ACCEPT

# ----- Reglas para red_dmz -----
# Servicios permitidos hacia DMZ
iptables -A FORWARD -d 172.172.30.10 -p tcp -m multiport --dports 3000,1631,3308,26,144,466,2587,994,180 -j ACCEPT

# Restricciones para DMZ
iptables -A FORWARD -i red_dmz -o red_admin -j REJECT
iptables -A FORWARD -i red_dmz -o red_servidores -j REJECT
iptables -A FORWARD -i red_dmz -o red_usuarios -j REJECT

# Bloqueos absolutos para DMZ
iptables -A FORWARD -d 172.172.30.10 -j DROP
iptables -A FORWARD -s 172.172.30.10 -j DROP

# ----- Reglas para red_servidores -----
# Rsync desde servidor específico
iptables -A FORWARD -s 172.172.20.20 -d 172.172.20.10 -p tcp --dport 873 -j ACCEPT
iptables -A FORWARD -s 172.172.20.20 -d 172.172.30.10 -p tcp --dport 873 -j ACCEPT

# Restricciones para servidores
iptables -A FORWARD -i red_servidores -o red_admin -j REJECT
iptables -A FORWARD -i red_servidores -o red_dmz -j REJECT
iptables -A FORWARD -i red_servidores -o red_usuarios -j REJECT

# Bloqueos absolutos para servidores
iptables -A FORWARD -d 172.172.20.10 -j DROP
iptables -A FORWARD -s 172.172.20.10 -j DROP

# ----- Reglas para red_usuarios -----
# Servicios de correo
iptables -A FORWARD -i red_usuarios -o red_servidores -d 172.172.20.10 -p tcp -m multiport --dports 25,143,465,587,993 -j ACCEPT

# Servicios de directorio
iptables -A FORWARD -i red_usuarios -o red_servidores -d 172.172.20.10 -p tcp -m multiport --dports 389,636 -j ACCEPT

# Servicios NetBIOS/SMB
iptables -A FORWARD -i red_usuarios -o red_servidores -d 172.172.20.10 -p udp -m multiport --dports 137,138 -j ACCEPT
iptables -A FORWARD -i red_usuarios -o red_servidores -d 172.172.20.10 -p tcp -m multiport --dports 139,1445 -j ACCEPT

# Otros servicios
iptables -A FORWARD -i red_usuarios -o red_servidores -d 172.172.20.10 -p tcp -m multiport --dports 631,8080,3307,80,443 -j ACCEPT

# Restricciones para usuarios
iptables -A FORWARD -i red_usuarios -o red_admin -j REJECT
iptables -A FORWARD -i red_usuarios -o red_dmz -j REJECT
iptables -A FORWARD -i red_usuarios -o red_servidores -j REJECT

# ================= REGLAS FINALES =================
# Bloqueo final explícito (redundante pero buena práctica)
iptables -A FORWARD -j DROP