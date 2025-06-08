#!/bin/bash
set -e

echo "Instalando docker ############################################################################"
# Forzar modo no interactivo
export DEBIAN_FRONTEND=noninteractive

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
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
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

# Habilita Docker para que inicie automáticamente al arrancar
systemctl enable docker

# Inicia Docker ahora mismo (por si aún no lo está)
systemctl start docker

# Verifica la instalación
docker --version
docker compose version
docker run --rm hello-world
