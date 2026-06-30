# Reto: Docker — Multi-servicio

Debes dockerizar una aplicación multi-servicio compuesta por backend (FastAPI + Redis), frontend (HTML/JS con Nginx) y Redis.

## Estructura del proyecto

```
app/backend/app.py          # API FastAPI (puerto 8000)
app/backend/requirements.txt # Dependencias
app/frontend/index.html      # Página HTML/JS
app/frontend/nginx.conf      # Configuración de Nginx
tests/verify.sh              # Script de verificación
```

## Archivos que debes crear

### `backend/Dockerfile`
- Multi-stage build
- Stage 1: imagen `python:3.12-slim`, instalar dependencias
- Stage 2: copiar solo lo necesario
- Puerto 8000
- Healthcheck: `curl -f http://localhost:8000/health || exit 1`

### `frontend/Dockerfile`
- Base `nginx:alpine`
- Copiar `index.html` y `nginx.conf`
- Puerto 80
- Healthcheck: `curl -f http://localhost:80/ || exit 1`

### `docker-compose.yml`
3 servicios:
- `backend`: construido desde `app/backend/`, variables `REDIS_HOST=redis`, `REDIS_PORT=6379`, healthcheck
- `frontend`: construido desde `app/frontend/`, puerto 80 mapeado al host, depends_on backend
- `redis`: imagen `redis:7-alpine`, volumen persistente en `/data`, healthcheck nativo

Requisitos adicionales:
- Volumen nombrado `redis_data` para persistencia
- Healthchecks en todos los servicios
- Red personalizada para comunicación entre servicios
- `restart: unless-stopped` en cada servicio

## Restricciones

- No uses imágenes no oficiales para servicios estándar
- Todo debe ser autocontenido y reproducible con `docker compose up`
- No modifiques los archivos de la aplicación existentes

## Criterios de evaluación (20 pts)

- `docker-compose up` funciona sin errores (3 pts)
- Backend responde en `/health` con Redis conectado (3 pts)
- Frontend carga desde Nginx (3 pts)
- Proxy `/api/` funciona correctamente (3 pts)
- Multi-stage build optimizado (3 pts)
- Healthchecks funcionando (2 pts)
- Volumen persistente para Redis (2 pts)
- Variables de entorno configuradas (1 pt)

## Formato de salida

```dockerfile
# filepath: backend/Dockerfile
# ...
```

```dockerfile
# filepath: frontend/Dockerfile
# ...
```

```yaml
# filepath: docker-compose.yml
# ...
```
