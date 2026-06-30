# Reto: CI/CD

## Objetivo

Crear pipelines CI/CD completos usando Jenkins (Jenkinsfile) y GitHub Actions.

## Requisitos

- Pipeline que ejecute: lint → test → build → deploy
- Stages condicionales (deploy solo en main)
- Notificaciones a Slack/email en fallo
- Seguridad: no hardcodear secrets
- Cache de dependencias para builds rápidos
- Estrategia de rollback en fallo

## Criterios de evaluación

- ✅ Pipeline funcional en Jenkins y/o GitHub Actions
- ✅ Stages bien definidos y ordenados
- ✅ Manejo de secretos correcto
- ✅ Notificaciones implementadas
- ✅ Rollback strategy documentada

## Archivos

- `Jenkinsfile`
- `.github/workflows/deploy.yml`
