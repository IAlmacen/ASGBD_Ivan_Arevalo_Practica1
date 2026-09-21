ación y Configuración del SGBD

Iván Arévalo Aznar

**Rol:** DBA  
**SGBD Elegido:** [PostgreSQL]  
**Entorno de despliegue:** Docker  

---

## 1. Análisis del Escenario y Planificación
### Requisitos y parámetros de cálculo:
- **Límite de RAM del servidor:** 2 GB (`2g`)
- **Conexiones ERP:** 3 instacias × 15 conexiones = 45 conexiones simultáneas mínimas para ERP.
- **Conexiones RRHH:** Conexiones estimadas para intranet pequeña.
- **Red permitida:** `172.30.0.0/24` (Aplicación).
- **Red bloqueada:** `172.31.0.0/24` (Visitantes).
- **Límite de espacio ERP:** [100 MB si es Oracle / N/A si es PostgreSQL]

---

## 2. Preparación de la Red y Contenedor en Docker
### Comandos de red y creación del contenedor
```bash
# Creación de la red para la aplicación
docker network create --subnet=172.30.0.0/24 xarxa_app

# Creación de la red de visitantes (para pruebas de rechazo)
docker network create --subnet=172.31.0.0/24 xarxa_visitants

# Despliegue del contenedor con límite de 2 GB de RAM
# (Insertar comando docker run o docker-compose)