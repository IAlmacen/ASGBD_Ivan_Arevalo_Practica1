# Instalación y Configuración del SGBD

**Iván Arévalo Aznar**

- **Rol:** DBA  
- **SGBD Elegido:** PostgreSQL  
- **Entorno de despliegue:** Docker  

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

## 2. Creación de la estructura

### 2.1 Configuración Docker Compose
Nos aseguramos que nuestro servidor sea desplegable en todo momento y que no se pierdan datos. La manera de conseguir este objetivo es mediante un docker compose en el que asignemos volúmenes y una versión fija de cada imagen.

```docker
networks:
  net_app:
    driver: bridge
    ipam:
      config:
        - subnet: 172.20.0.0/16
  net_visitors:
    driver: bridge
    ipam:
      config:
        - subnet: 172.21.0.0/16

volumes:
  pg_sys_data:
  pg_erp_data:
  pg_rrhh_data:
  pg_logs:

services:
  db_server:
    image: postgres:16.2-alpine  # Versión fijada 
    container_name: postgres_db
    restart: always              # Configuración contra caídas (Requisit 7)
    environment:
      POSTGRES_USER: ${POSTGRES_USER}
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}
      POSTGRES_DB: ${POSTGRES_DB}
    volumes:
      # Datos del sistema
      - pg_sys_data:/var/lib/postgresql/data
      # Volúmenes separados de ERP y RRHH (Tablespaces)
      - pg_erp_data:/mnt/tablespaces/erp
      - pg_rrhh_data:/mnt/tablespaces/rrhh
      # Log persistente
      - pg_logs:/var/log/postgresql
      # Archivos de configuración personalizada.
      - ./postgresql.conf:/etc/postgresql/postgresql.conf:ro
      - ./pg_hba.conf:/etc/postgresql/pg_hba.conf:ro
    command: >
      postgres # Para cargar nuestros archivos de configuración. 
      -c config_file=/etc/postgresql/postgresql.conf
      -c hba_file=/etc/postgresql/pg_hba.conf
    deploy:
      resources:
        limits:
          memory: 2048M         # Límite de 2 GB de RAM
    networks:
      - net_app
      - net_visitors
    # Sin ports publicados al host

  # Client de prueba de la red de aplicación
  client_app:
    image: postgres:16.2-alpine
    container_name: client_app
    entrypoint: ["sleep", "infinity"]
    networks:
      - net_app
  # "Sleep" "infinity" nos sirve para que realicen solo las mínimas acciones posibles.

  # Cliente de prueba de la red de visitantes
  client_visitor:
    image: postgres:16.2-alpine
    container_name: client_visitor
    entrypoint: ["sleep", "infinity"]
    networks:
      - net_visitors
```
---

### 2.2 Archivos de configuración PostgreSQL
A continuación, crearemos un archivo de configuración que gestionará parámetros internos de nuestra base de datos, tales cómo el número de conexiones y la memoria RAM asignada para cada proceso.

```
# --- CONNEXIONES (Requisito 4) ---
max_connections = 60
listen_addresses = '*'

# --- MEMORIA (Requisito 3) ---
# Memòria compartida
shared_buffers = 512MB
effective_cache_size = 1280MB

# Memòria por proceso
work_mem = 10MB
maintenance_work_mem = 64MB

# --- LOGS  (Requisito 6) ---
logging_collector = on
log_destination = 'csvlog'
log_directory = 'log'
log_filename = 'postgresql-%Y-%m-%d_%H%M%S.log'
log_connections = on
log_disconnections = on
```
---

### 2.3 Configuración de redes del contenedor
Configuramos que conexiones pueden acceder a nuestro servidor de bases de datos y cuáles prohibímos.

```bash
# TYPE  DATABASE        USER            ADDRESS                 METHOD

# Connexions locals de manteniment dins del mateix contenidor
local   all             all                                     trust

# Permetre connexions NOMÉS des de la xarxa d'aplicació (172.20.0.0/16)
host    all             all             172.20.0.0/16           md5

# Rebutjar explicat qualsevol intent des de la xarxa de visitants (172.21.0.0/16)
host    all             all             172.21.0.0/16           reject

# Rebutjar qualsevol altra conexió
host    all             all             all                     reject
```

---

### 2.4 Archivo .env
En este archivo guardaremos el usuario y la contraseña a nuestra base de datos.

```
POSTGRES_USER=admin_ivan
POSTGRES_PASSWORD=ivan!1234
POSTGRES_DB=postgres
```
--- 
## 3. Demonstraciones

### 3.1 Persistencia tras reinicio
Ejecutamos los siguientes comandos para comprobar persistencia:
```bash
# 1. Iniciar entorn i crear una taula de prova
docker compose up -d
docker exec -it postgres_db psql -U admin_user -d postgres -c "CREATE TABLE prova_persistence (id int);"

# 2. Destruir completament el contenidor (sense esborrar volums)
docker compose down

# 3. Tornar a crear el servidor
docker compose up -d

# 4. Comprovar que les dades continuen allí
docker exec -it postgres_db psql -U admin_user -d postgres -c "SELECT * FROM prova_persistence;"
```
---
\
Probamos a levantar el contenedor y creamos una tabla.

![persitencia.png](img/persistencia1.png)

Después, comprobamos que la tabla sigue existiendo (Si la tabla no existiese, nos saldría un error.)

![persistencia2.png](img/persistencia2.png)

---

### 3.2 Comprobar política de conexiones
Ejecutamos los siguientes comandos para confirmar que acepte las conexiones desde client_app y rechace las de client_visitor.

![conexiones.png](img/conexiones.png)

### 3.3 Comprobar memoria

### 3.4 Comprobar connexions

### 3.5 Comprobar emmagatzematge
Primero nos aseguramos de que el usuario postgres tenga acceso a los tablespaces. Para ello, entraremos en el servidor y usaremos el comando chown postgres:postgres -R /mnt/tablespaces.

Una vez hecho, crearemos los dos tablespaces, ERP y RRHH.

![tablespaces_create.png](img/tablespaces_create.png)

Después, creamos las bases de datos y revisamos que estén asociadas a los tablespaces:

![databases.png](img/databases.png)

Reiniciamos y comprobamos que se mantengan:

![persistance.png](img/persistance.png)