#!/bin/bash

# Verifica que IP forwarding siga activo y que iptables tenga al menos una regla
if sysctl net.ipv4.ip_forward | grep -q '1' && iptables -L -n | grep -q 'Chain'; then
    exit 0
else
    exit 1
fi
