# Docker Symfony Boilerplate - Makefile
# =====================================

UID = $(shell id -u)

# Prefijo de los contenedores: se toma de PROJECT_NAME en .env; si no esta
# definido, se usa "symfony" (mismo valor que el default de docker-compose.yml).
PROJECT_NAME := $(shell grep -E '^[[:space:]]*PROJECT_NAME[[:space:]]*=' .env 2>/dev/null | tail -n1 | cut -d= -f2- | tr -d "[:space:]\"'")
ifeq ($(strip $(PROJECT_NAME)),)
PROJECT_NAME := symfony
endif

# Nombres de contenedores
DOCKER_APP = $(PROJECT_NAME)-app
DOCKER_DB = $(PROJECT_NAME)-mysql
DOCKER_MAIL = $(PROJECT_NAME)-mailhog

.DEFAULT_GOAL := help

# =====================================
# Comandos de Ayuda
# =====================================

help: ## Mostrar esta ayuda
	@echo 'Uso: make [comando]'
	@echo ''
	@echo 'Comandos disponibles:'
	@egrep '^(.+)\:\ ##\ (.+)' ${MAKEFILE_LIST} | column -t -c 2 -s ':#'

check: ## Verificar UID y nombres de contenedores
	@echo "UID: ${UID}"
	@echo "PROJECT_NAME: ${PROJECT_NAME}"
	@echo "Contenedores: ${DOCKER_APP}, ${DOCKER_DB}, ${DOCKER_MAIL}"

# =====================================
# Gestión de Contenedores
# =====================================

build: ## Construir imágenes Docker
	U_ID=${UID} docker compose build

start: ## Iniciar contenedores
	U_ID=${UID} docker compose up -d

stop: ## Detener contenedores
	U_ID=${UID} docker compose stop

down: ## Detener y eliminar contenedores
	U_ID=${UID} docker compose down

restart: ## Reiniciar contenedores
	$(MAKE) stop && $(MAKE) start

rebuild: ## Reconstruir todo desde cero
	$(MAKE) down && $(MAKE) build && $(MAKE) start

status: ## Ver estado de los contenedores
	docker compose ps

logs: ## Ver logs de todos los contenedores
	docker compose logs -f

logs-app: ## Ver logs del contenedor de la aplicación
	docker compose logs -f app

logs-db: ## Ver logs del contenedor de MySQL
	docker compose logs -f mysql

logs-mail: ## Ver logs del contenedor de MailHog
	docker compose logs -f mailhog

# =====================================
# Acceso a Contenedores
# =====================================

ssh-app: ## Acceso bash al contenedor de la aplicación
	U_ID=${UID} docker exec -it --user ${UID} ${DOCKER_APP} bash

ssh-db: ## Acceso bash al contenedor de MySQL
	docker exec -it ${DOCKER_DB} bash

ssh-mail: ## Acceso bash al contenedor de MailHog
	docker exec -it ${DOCKER_MAIL} sh

# =====================================
# Comandos de Desarrollo
# =====================================

composer-install: ## Instalar dependencias de Composer
	U_ID=${UID} docker exec --user ${UID} ${DOCKER_APP} composer install --no-interaction

composer-update: ## Actualizar dependencias de Composer
	U_ID=${UID} docker exec --user ${UID} ${DOCKER_APP} composer update --no-interaction

composer-require: ## Agregar dependencia (uso: make composer-require PKG=vendor/package)
	U_ID=${UID} docker exec --user ${UID} ${DOCKER_APP} composer require $(PKG)

cache-clear: ## Limpiar caché de Symfony
	U_ID=${UID} docker exec --user ${UID} ${DOCKER_APP} bin/console cache:clear

# =====================================
# Base de Datos
# =====================================

restore-db: ## Restaurar BD desde docker/database/project_database.sql
	docker cp ./docker/database/project_database.sql ${DOCKER_DB}:/tmp/project_database.sql
	docker exec ${DOCKER_DB} sh -c 'mysql -uroot -p$${MYSQL_ROOT_PASSWORD} -e "DROP DATABASE IF EXISTS $${MYSQL_DATABASE};"'
	docker exec ${DOCKER_DB} sh -c 'mysql -uroot -p$${MYSQL_ROOT_PASSWORD} -e "CREATE DATABASE $${MYSQL_DATABASE} CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"'
	docker exec ${DOCKER_DB} sh -c 'mysql -uroot -p$${MYSQL_ROOT_PASSWORD} $${MYSQL_DATABASE} < /tmp/project_database.sql'

.PHONY: migrations migrations-test
migrations: ## Ejecutar migraciones (dev/prod)
	U_ID=${UID} docker exec --user ${UID} ${DOCKER_APP} bin/console doctrine:migration:migrate -n

migrations-test: ## Ejecutar migraciones (test)
	U_ID=${UID} docker exec --user ${UID} ${DOCKER_APP} bin/console doctrine:migration:migrate -n --env=test

schema-validate: ## Validar esquema de Doctrine
	U_ID=${UID} docker exec --user ${UID} ${DOCKER_APP} bin/console doctrine:schema:validate

schema-update: ## Actualizar esquema de BD (solo desarrollo)
	U_ID=${UID} docker exec --user ${UID} ${DOCKER_APP} bin/console doctrine:schema:update --force

# =====================================
# Tests
# =====================================

# Binario de PHPUnit: las recetas actuales de Symfony instalan bin/phpunit; se
# mantiene el fallback a vendor/bin para proyectos que no lo tengan. Sin -c, para
# que PHPUnit descubra solo su config (phpunit.xml, phpunit.dist.xml o phpunit.xml.dist).
PHPUNIT_BIN = $$(if [ -x bin/phpunit ]; then echo bin/phpunit; elif [ -x vendor/bin/phpunit ]; then echo vendor/bin/phpunit; else echo vendor/bin/simple-phpunit; fi)

.PHONY: tests tests-coverage
tests: ## Ejecutar tests con PHPUnit
	U_ID=${UID} docker exec --user ${UID} ${DOCKER_APP} sh -c '$(PHPUNIT_BIN)'

tests-coverage: ## Ejecutar tests con cobertura (requiere XDEBUG_MODE=coverage)
	U_ID=${UID} docker exec --user ${UID} -e XDEBUG_MODE=coverage ${DOCKER_APP} sh -c '$(PHPUNIT_BIN) --coverage-html var/coverage'

# =====================================
# Limpieza
# =====================================

clean: ## Eliminar contenedores, volúmenes e imágenes del proyecto
	U_ID=${UID} docker compose down -v --rmi local
	@echo "Limpieza completada"

clean-all: ## Eliminar todo incluyendo imágenes descargadas
	U_ID=${UID} docker compose down -v --rmi all
	@echo "Limpieza completa realizada"
