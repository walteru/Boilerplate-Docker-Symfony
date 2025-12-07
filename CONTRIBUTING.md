# Guía de Contribución

Gracias por tu interés en contribuir a este proyecto. Esta guía te ayudará a comenzar.

## Cómo Contribuir

### Reportar Bugs

1. Verifica que el bug no haya sido reportado previamente en [Issues](../../issues)
2. Si no existe, crea un nuevo issue usando la plantilla de **Bug Report**
3. Incluye toda la información relevante:
   - Sistema operativo
   - Versiones de Docker y Docker Compose
   - Pasos para reproducir
   - Logs relevantes (`make logs`)

### Sugerir Funcionalidades

1. Revisa los issues existentes para evitar duplicados
2. Crea un nuevo issue usando la plantilla de **Feature Request**
3. Describe claramente la funcionalidad y su caso de uso

### Enviar Pull Requests

1. **Fork** el repositorio
2. **Clona** tu fork localmente
3. **Crea una rama** para tu cambio:
   ```bash
   git checkout -b feature/mi-nueva-funcionalidad
   ```
4. **Realiza los cambios** siguiendo las convenciones del proyecto
5. **Prueba** tus cambios:
   ```bash
   make rebuild
   make start
   # Verificar que todo funcione
   ```
6. **Commit** con mensajes descriptivos:
   ```bash
   git commit -m "feat: agregar soporte para PostgreSQL"
   ```
7. **Push** a tu fork:
   ```bash
   git push origin feature/mi-nueva-funcionalidad
   ```
8. **Crea el Pull Request** desde GitHub

## Convenciones de Commits

Usamos [Conventional Commits](https://www.conventionalcommits.org/):

- `feat:` Nueva funcionalidad
- `fix:` Corrección de bug
- `docs:` Cambios en documentación
- `refactor:` Refactorización de código
- `test:` Agregar o modificar tests
- `chore:` Tareas de mantenimiento

## Estructura del Proyecto

```
docker/
├── database/        # Configuración de MySQL
└── php-apache/      # Configuración de PHP + Apache
```

### Archivos Importantes

| Archivo | Propósito |
|---------|-----------|
| `docker-compose.yml` | Orquestación de servicios |
| `Makefile` | Comandos de automatización |
| `docker/php-apache/Dockerfile` | Imagen PHP personalizada |
| `docker/php-apache/php.ini` | Configuración PHP |
| `docker/php-apache/xdebug.ini` | Configuración Xdebug |

## Estándares de Código

### Dockerfile

- Usar imágenes base oficiales
- Minimizar capas combinando comandos RUN
- Limpiar cachés de gestores de paquetes
- Documentar argumentos y variables de entorno

### Makefile

- Documentar cada target con `##`
- Usar variables para valores repetidos
- Mantener comandos atómicos y reutilizables

### Documentación

- Mantener README actualizado con cambios
- Usar español para documentación
- Incluir ejemplos de uso

## Testing de Cambios

Antes de enviar un PR, verifica:

1. **Build exitoso**: `make build`
2. **Contenedores inician**: `make start`
3. **Servicios responden**:
   - App: http://localhost:1500
   - MySQL: puerto 1000
   - MailHog: http://localhost:8025
4. **Comandos funcionan**: `make help`

## Preguntas

Si tienes dudas, abre un issue con la etiqueta `question`.

---

¡Gracias por contribuir!
