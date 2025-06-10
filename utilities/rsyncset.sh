#!/bin/bash
set -e

# Configuración
RSYNC_PORT=873
CONFIG_FILE="/etc/rsyncd.conf"
SECRETS_FILE="/etc/rsyncd.secrets"
BACKUP_PATH="/setup/logs/docker/dockerd.log"

echo "[INFO] Configurando rsync..."

# Verificar rsync instalado
if ! command -v rsync &>/dev/null; then
    echo "[ERROR] Rsync no está instalado"
    exit 1
fi

# Crear configuración
cat > "$CONFIG_FILE" <<EOF
pid file = /var/run/rsyncd.pid
lock file = /var/run/rsync.lock
log file = /var/log/rsync.log
port = $RSYNC_PORT
use chroot = no
read only = no
timeout = 300

[backup]
    path = $(dirname "$BACKUP_PATH")
    comment = Directorio de backups
    uid = root
    gid = root
    read only = no
    auth users = backupuser
    secrets file = $SECRETS_FILE
EOF

# Configurar autenticación
echo "backupuser:password123" > "$SECRETS_FILE"
chmod 600 "$SECRETS_FILE"

# Crear directorio si no existe
mkdir -p "$(dirname "$BACKUP_PATH")"
touch "$BACKUP_PATH"

echo "[INFO] Iniciando rsync en puerto $RSYNC_PORT..."
rsync --daemon --no-detach --config="$CONFIG_FILE" &

# Verificación
sleep 2
if ! ss -tuln | grep -q ":$RSYNC_PORT "; then
    echo "[ERROR] Rsync no se inició correctamente"
    exit 1
fi

echo "[OK] Rsync configurado correctamente en puerto $RSYNC_PORT"