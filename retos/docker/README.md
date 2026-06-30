# Reto: Docker

## Objetivo

Dockerizar una aplicación multi-servicio compuesta por:

- **Backend** — API REST en Python con FastAPI + Redis para caché
- **Frontend** — HTML/JS servido por Nginx como reverse proxy
- **Redis** — Almacenamiento en caché
- **Nginx** — Proxy inverso que enruta `/api/` al backend

## Archivos proporcionados

```
app/backend/app.py
app/backend/requirements.txt
app/frontend/index.html
app/frontend/nginx.conf
tests/verify.sh
```

## Tareas

1. **Dockerfile para el backend** (multi-stage)
   - Stage 1: build con imagen base `python:3.12-slim`, instalar dependencias
   - Stage 2: copiar solo lo necesario desde stage 1
   - Puerto `8000`
   - Healthcheck: `curl -f http://localhost:8000/health || exit 1`

2. **Dockerfile para el frontend** (nginx)
   - Base `nginx:alpine`
   - Copiar `index.html` y `nginx.conf`
   - Puerto `80`
   - Healthcheck: `curl -f http://localhost:80/ || exit 1`

3. **docker-compose.yml** con 3 servicios:
   - `backend` — construido desde `app/backend`, variables de entorno `REDIS_HOST` y `REDIS_PORT`
   - `frontend` — construido desde `app/frontend`, puerto `80` mapeado al host, depende de `backend`
   - `redis` — imagen oficial `redis:7-alpine`, volumen persistente en `/data`, healthcheck nativo

4. **Requisitos adicionales:**
   - Volumen nombrado `redis_data` para persistencia de Redis
   - Healthchecks en todos los servicios
   - Red personalizada para comunicación entre servicios
   - `restart: unless-stopped` en cada servicio

## Criterios de evaluación (20 puntos)

| Criterio | Puntos |
|---|---|
| `docker-compose up` funciona sin errores | 3 |
| Backend responde en `/health` con Redis conectado | 3 |
| Frontend carga desde Nginx en el puerto mapeado | 3 |
| Proxy `/api/` desde Nginx al backend funciona | 3 |
| Multi-stage build en backend (imagen optimizada) | 3 |
| Healthchecks funcionando en todos los servicios | 2 |
| Volumen persistente para Redis | 2 |
| Variables de entorno configuradas correctamente | 1 |

## Verificación

```bash
chmod +x tests/verify.sh
./tests/verify.sh
```
