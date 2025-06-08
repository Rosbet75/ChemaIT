#!/bin/bash
set -e

LOCKFILE="/tmp/docker_install.lock"
if [ -f "$LOCKFILE" ]; then
  echo "[INFO] Instalación ya realizada previamente. Validando instalación..."
  docker --version && docker compose version && exit 0
  echo "[WARN] Docker no está funcionando correctamente. Continuando con reinstalación..."
else
  touch "$LOCKFILE"
fi

# Detecta si el sistema usa systemd
USE_SYSTEMD=$(ps -p 1 -o comm= | grep -q systemd && echo yes || echo no)

echo "Instalando docker ############################################################################"
# Forzar modo no interactivo
export DEBIAN_FRONTEND=noninteractive
unset GPG_TTY  # Evita errores con GPG sin tty

# Configura la zona horaria automáticamente para evitar prompts
ln -fs /usr/share/zoneinfo/America/Mexico_City /etc/localtime
echo "tzdata tzdata/Areas select America" | debconf-set-selections
echo "tzdata tzdata/Zones/America select Mexico_City" | debconf-set-selections
apt-get install -y tzdata

# Actualiza APT y herramientas necesarias
apt-get update
apt-get install -y \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

# Crea el directorio de llaves
install -m 0755 -d /etc/apt/keyrings

# Descarga la clave GPG
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --batch --yes --dearmor -o /etc/apt/keyrings/docker.gpg
chmod a+r /etc/apt/keyrings/docker.gpg

# Agrega el repositorio de Docker
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
  https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | \
  tee /etc/apt/sources.list.d/docker.list > /dev/null

# Instala Docker y sus herramientas
apt-get update
apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# # Si el sistema usa systemd, habilita e inicia Docker
# if [ "$USE_SYSTEMD" = "yes" ]; then
#   systemctl enable docker || echo "[WARN] No se pudo habilitar Docker."
#   systemctl start docker || echo "[WARN] No se pudo iniciar Docker."
# else
#   echo "[INFO] El sistema no usa systemd. No se puede habilitar Docker al inicio automáticamente."
# fi

# # Verifica la instalación
# docker --version || echo "[ERROR] No se pudo verificar la versión de Docker."
# docker compose version || echo "[ERROR] No se pudo verificar la versión de Docker Compose."

# # Ejecuta contenedor de prueba sin abortar si falla
# set +e
# docker run --rm hello-world
# if [ $? -ne 0 ]; then
#   echo "[ERROR] No se pudo ejecutar el contenedor de prueba."
# fi
# set -e



# Si no se está usando systemd, iniciar dockerd manualmente
if [ "$USE_SYSTEMD" = "no" ]; then
  echo "[INFO] Iniciando dockerd manualmente..."
  
  # Crea el directorio si no existe
  mkdir -p /var/run

  # Inicia dockerd en segundo plano, log a un archivo
  dockerd > /setup/logs/docker/dockerd.log 2>&1 &
  
  # Espera a que esté disponible el socket de Docker (máx 15s)
  for i in {1..15}; do
    if [ -S /var/run/docker.sock ]; then
      echo "[INFO] Docker daemon está listo."
      break
    fi
    echo "[INFO] Esperando que dockerd arranque... ($i)"
    sleep 1
  done

  # Validación final
  if ! docker info &>/dev/null; then
    echo "[ERROR] El demonio Docker no se pudo iniciar correctamente."
    exit 1
  fi
fi

cd /setup
docker compose up