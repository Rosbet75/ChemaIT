#!/bin/bash

# Nombre de la clave sin extensión
KEY_NAME="llave_servicios_internos"

# Ruta absoluta para guardar las claves
KEY_DIR="/keys"
PRIVATE_KEY_PATH="${KEY_DIR}/${KEY_NAME}.pem"
PUBLIC_KEY_PATH="${PRIVATE_KEY_PATH}.pub"

# Crear el directorio si no existe
mkdir -p "$KEY_DIR"

# Generar las claves, sobrescribiendo si ya existen
ssh-keygen -t rsa -b 4096 -f "$PRIVATE_KEY_PATH" -N "" -C "$USER@localhost"

# Crear el directorio ~/.ssh si no existe
mkdir -p "$HOME/.ssh"
chmod 700 "$HOME/.ssh"

# Copiar la clave pública al authorized_keys, evitando duplicados
grep -qxFf "$PUBLIC_KEY_PATH" "$HOME/.ssh/authorized_keys" 2>/dev/null || cat "$PUBLIC_KEY_PATH" >> "$HOME/.ssh/authorized_keys"

# Asegurar permisos correctos
chmod 600 "$HOME/.ssh/authorized_keys"

echo "✅ Claves generadas en $KEY_DIR y habilitadas para acceso SSH a $USER@localhost"
