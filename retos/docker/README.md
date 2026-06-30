# Reto: Docker

## Objetivo

Dockerizar una aplicación multi-servicio compuesta por:

- Frontend (React/Vue)
- Backend API (Node/Python/Go)
- Base de datos (Postgres)
- Cache (Redis)
- Nginx como reverse proxy

## Requisitos

- `docker-compose.yml` funcional
- Multi-stage builds para optimizar tamaño
- Volúmenes para datos persistentes
- Healthchecks en cada servicio
- Variables de entorno para configuración

## Criterios de evaluación

- ✅ `docker-compose up` funciona sin errores
- ✅ Todos los servicios se comunican entre sí
- ✅ Tamaño de imágenes optimizado
- ✅ Configuración de red adecuada
- ✅ Logs accesibles desde el host
