# 🏢 Infraestructura Empresarial Virtualizada con Docker

Proyecto de laboratorio que **emula la infraestructura completa de una empresa** utilizando contenedores Docker, simulando servicios corporativos, red interna, dispositivos de usuarios y controles de seguridad.

## 🧩 Descripción general

Este proyecto consiste en la construcción de una **red empresarial virtual**, completamente contenida en Docker, donde cada componente de la infraestructura (servidores, bases de datos, equipos de empleados, dispositivos de red y servicios críticos) es representado por uno o más contenedores.

El objetivo es **replicar el funcionamiento real de una empresa**, incluyendo segmentación de red, servicios internos, acceso externo controlado y políticas de seguridad a nivel de red.

## 🖧 Arquitectura simulada

La infraestructura emula los siguientes componentes:

### Dispositivos de red
- Routers virtuales
- Switches virtuales
- Segmentación de red mediante múltiples redes Docker
- Enrutamiento entre subredes

### Servicios empresariales
- Servidor de correo interno
- Servicio de impresión en red
- Servidor web corporativo
- Active Directory / gestión de identidades
- Sistema de respaldo (backup)
- Servidor de base de datos corporativa

### Equipos de usuario
- Contenedores que representan computadoras de empleados
- Acceso a servicios internos según políticas de red

## 🌐 Conectividad y seguridad

- Acceso desde fuera de la red corporativa hacia servicios específicos
- Configuración manual de **iptables** para:
  - Control de tráfico
  - Filtrado de paquetes
  - NAT
  - Reglas de acceso entre segmentos
- Separación entre red interna, DMZ y acceso externo

## 🛠️ Tecnologías utilizadas

- **Docker**
- **Docker Compose**
- Contenedores Linux personalizados
- iptables
- Redes bridge personalizadas
- Servicios corporativos open source
- Bases de datos relacionales

## 🎯 Objetivo del proyecto

Simular una infraestructura empresarial realista para:
- Pruebas de redes y seguridad
- Aprendizaje de administración de sistemas
- Análisis de flujos de red
- Validación de políticas de acceso y segmentación

---

