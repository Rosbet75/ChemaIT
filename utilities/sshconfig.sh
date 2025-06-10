#!/bin/bash

SSHD_CONFIG="/etc/ssh/sshd_config"

# Asegura que se use el puerto 22
sed -i 's/^#\?Port .*/Port 22/' "$SSHD_CONFIG"

# Permite login como root
sed -i 's/^#\?PermitRootLogin .*/PermitRootLogin yes/' "$SSHD_CONFIG"

# Habilita autenticación por clave pública (pem)
sed -i 's/^#\?PubkeyAuthentication .*/PubkeyAuthentication yes/' "$SSHD_CONFIG"
sed -i 's|^#\?AuthorizedKeysFile .*|AuthorizedKeysFile .ssh/authorized_keys|' "$SSHD_CONFIG"
service ssh start