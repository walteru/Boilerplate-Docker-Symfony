# Docker Symfony Boilerplate

![Docker](https://img.shields.io/badge/Docker-2496ED?style=flat&logo=docker&logoColor=white)
![PHP](https://img.shields.io/badge/PHP-8.2-777BB4?style=flat&logo=php&logoColor=white)
![Symfony](https://img.shields.io/badge/Symfony-000000?style=flat&logo=symfony&logoColor=white)
![MySQL](https://img.shields.io/badge/MySQL-8.0-4479A1?style=flat&logo=mysql&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-green.svg)

Entorno Docker listo para desarrollar aplicaciones Symfony con PHP 8.2, Apache, MySQL 8.0 y MailHog.

## Inicio Rápido

```bash
# 1. Clonar el repositorio
git clone git@github.com:walteru/Boilerplate-Docker-Symfony.git
cd Boilerplate-Docker-Symfony

# 2. Copiar variables de entorno
cp .env.example .env

# 3. Construir e iniciar
make build
make start

# 4. Verificar funcionamiento
echo "<?php phpinfo();" > src/public/index.php
# Abrir http://localhost:1500
```

## Requisitos Previos

- [Docker](https://docs.docker.com/get-docker/) >= 20.10
- [Docker Compose](https://docs.docker.com/compose/install/) >= 2.0
- [Make](https://www.gnu.org/software/make/)
- [Git](https://git-scm.com/)

## Estructura del Proyecto

```
docker-symfony-boilerplate/
├── .github/
│   └── ISSUE_TEMPLATE/      # Templates para issues
├── docker/
│   ├── database/
│   │   ├── Dockerfile       # Imagen MySQL 8.0
│   │   └── databases.sql    # Script inicialización BD
│   └── php-apache/
│       ├── Dockerfile       # Imagen PHP 8.2 + Apache
│       ├── default.conf     # VirtualHost Apache
│       ├── php.ini          # Configuración PHP
│       └── xdebug.ini       # Configuración Xdebug 3
├── docs/
│   └── images/              # Imágenes documentación
├── src/                     # Tu proyecto Symfony aquí
├── .env.example             # Variables de entorno ejemplo
├── .gitignore
├── CONTRIBUTING.md
├── docker-compose.yml
├── LICENSE
├── Makefile
└── README.md
```

## Servicios Incluidos

| Servicio | Puerto | Descripción |
|----------|--------|-------------|
| **App** | `localhost:1500` | PHP 8.2 + Apache |
| **MySQL** | `localhost:1000` | MySQL 8.0.43 |
| **MailHog** | `localhost:8025` | Interfaz web de correos |
| **SMTP** | `localhost:1025` | Servidor SMTP para pruebas |

## Variables de Entorno

Copia `.env.example` a `.env` y ajusta según tu entorno:

```env
# Puertos
APP_PORT=1500
MYSQL_PORT=1000
MAILHOG_WEB_PORT=8025
MAILHOG_SMTP_PORT=1025

# MySQL
MYSQL_ROOT_PASSWORD=root
MYSQL_DATABASE=project_database

# Xdebug
XDEBUG_CLIENT_HOST=172.17.0.1
XDEBUG_CLIENT_PORT=9003
```

### Configuración de Xdebug por Sistema Operativo

| Sistema | XDEBUG_CLIENT_HOST |
|---------|-------------------|
| **Linux** | Ejecutar `ip a \| grep docker0` y usar esa IP |
| **macOS** | `host.docker.internal` |
| **Windows (WSL2)** | `host.docker.internal` |

## Comandos Disponibles

### Gestión de Contenedores

```bash
make build       # Construir imágenes Docker
make start       # Iniciar contenedores
make stop        # Detener contenedores
make down        # Detener y eliminar contenedores
make restart     # Reiniciar contenedores
make rebuild     # Reconstruir todo desde cero
make status      # Ver estado de contenedores
```

### Logs

```bash
make logs        # Ver logs de todos los contenedores
make logs-app    # Ver logs de la aplicación
make logs-db     # Ver logs de MySQL
make logs-mail   # Ver logs de MailHog
```

### Acceso a Contenedores

```bash
make ssh-app     # Bash en contenedor PHP
make ssh-db      # Bash en contenedor MySQL
make ssh-mail    # Shell en contenedor MailHog
```

### Desarrollo

```bash
make composer-install              # Instalar dependencias
make composer-update               # Actualizar dependencias
make composer-require PKG=vendor/pkg  # Agregar dependencia
make cache-clear                   # Limpiar caché Symfony
```

### Base de Datos

```bash
make restore-db       # Restaurar BD desde SQL
make migrations       # Ejecutar migraciones
make migrations-test  # Migraciones en entorno test
make schema-validate  # Validar esquema Doctrine
make schema-update    # Actualizar esquema BD
```

### Tests

```bash
make tests           # Ejecutar PHPUnit
make tests-coverage  # Tests con cobertura HTML
```

### Limpieza

```bash
make clean       # Eliminar contenedores y volúmenes
make clean-all   # Eliminar todo incluyendo imágenes
```

## Configuración de tu Proyecto Symfony

### Opción 1: Clonar proyecto existente

```bash
cd src
git clone git@github.com:tu-usuario/tu-proyecto.git .
cd ..
make composer-install
```

### Opción 2: Crear nuevo proyecto Symfony

```bash
make ssh-app
symfony new . --webapp
exit
```

### Configuración de Base de Datos en Symfony

En tu archivo `src/.env` o `src/.env.local`:

```env
DATABASE_URL="mysql://root:root@mysql:3306/project_database?serverVersion=8.0"
```

### Configuración de Correo en Symfony

```env
MAILER_DSN=smtp://mailhog:1025
```

## Configuración de Depuración (VS Code)

### Prerequisito: Configurar IP de Xdebug

Antes de iniciar, asegúrate de tener configurado `XDEBUG_CLIENT_HOST` en tu archivo `.env`:

| Sistema | Valor |
|---------|-------|
| **Linux** | Ejecutar `ip a \| grep docker0` y usar esa IP (ej: `172.17.0.1`) |
| **macOS** | `host.docker.internal` |
| **Windows (WSL2)** | `host.docker.internal` |

Después de cambiar el valor, reinicia los contenedores: `make restart`

### 1. Conectar a Remote Container

1. Instalar extensión **Dev Containers** en VS Code
2. Abrir **Remote Explorer** en la barra lateral izquierda

![Remote Explorer](docs/images/remote.png)

3. Seleccionar el contenedor `symfony-app` y hacer clic en **Attach**

![Attach to Container](docs/images/add_remote.png)

### 2. Instalar extensión PHP Debug

Una vez conectado al contenedor, instalar la extensión **PHP Debug by Xdebug**:

![Extensión PHP Debug](docs/images/extension.png)

### 3. Crear configuración de debug

1. Ir a **Ejecutar y Depurar** (Ctrl+Shift+D)
2. Hacer clic en **crear un archivo launch.json**

![Agregar Configuración](docs/images/add_config.png)

3. Seleccionar **PHP** y reemplazar el contenido con:

```json
{
    "version": "0.2.0",
    "configurations": [
        {
            "name": "Listen for Xdebug",
            "type": "php",
            "request": "launch",
            "port": 9003,
            "pathMappings": {
                "/var/www/html": "${workspaceFolder}"
            }
        }
    ]
}
```

### 4. Iniciar depuración

1. Agregar breakpoints haciendo clic en el margen izquierdo del código
2. Presionar **F5** o hacer clic en el botón verde de play
3. Realizar una petición a la aplicación (http://localhost:1500)

![Iniciar Depuración](docs/images/init_debug.png)

> **Tip:** Si el debugger no conecta, verifica que `XDEBUG_CLIENT_HOST` en `.env` sea correcto y que el puerto 9003 no esté bloqueado por un firewall.

## Software Incluido en Contenedor PHP

- PHP 8.2 con extensiones: intl, pdo, gd, zip, pdo_mysql, opcache, xdebug, apcu
- Apache 2.4 con mod_rewrite
- Composer (última versión)
- Node.js 18.x con npm y Yarn
- Symfony CLI
- Git

### Alias Bash Disponibles

| Alias | Comando |
|-------|---------|
| `sf` | `bin/console` |
| `cc` | `bin/console cache:clear` |
| `dsv` | `bin/console doctrine:schema:validate` |
| `dsu` | `bin/console doctrine:schema:update` |
| `dmm` | `bin/console doctrine:migration:migrate` |
| `dms` | `bin/console doctrine:migration:status` |

## Solución de Problemas

### La aplicación no carga

```bash
# Verificar que los contenedores estén corriendo
make status

# Ver logs para errores
make logs-app
```

### Error de permisos en archivos

```bash
# Verificar UID
make check

# Reconstruir con UID correcto
make rebuild
```

### MySQL no inicia

```bash
# Ver logs de MySQL
make logs-db

# Limpiar volumen y reiniciar
make clean
make build
make start
```

### Xdebug no conecta

1. Verificar `XDEBUG_CLIENT_HOST` en `.env`
2. Asegurar que el puerto 9003 no esté bloqueado
3. Reiniciar contenedores: `make restart`

### Correos no llegan a MailHog

Verificar configuración MAILER_DSN en tu proyecto Symfony:
```env
MAILER_DSN=smtp://mailhog:1025
```

## Contribuir

Las contribuciones son bienvenidas. Por favor, lee [CONTRIBUTING.md](CONTRIBUTING.md) para más detalles.

## Licencia

Este proyecto está bajo la Licencia MIT. Ver [LICENSE](LICENSE) para más detalles.
