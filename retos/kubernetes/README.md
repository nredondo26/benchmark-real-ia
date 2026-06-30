# Reto: Kubernetes

## Objetivo

Desplegar una aplicación web completa en Kubernetes con alta disponibilidad.

## Recursos a crear

- Deployments con resource limits y requests
- Services (ClusterIP, LoadBalancer)
- Ingress con TLS
- ConfigMaps y Secrets
- Horizontal Pod Autoscaler
- Persistent Volume Claims
- Network Policies restrictivas
- Liveness y Readiness probes

## Criterios de evaluación

- ✅ Manifiestos válidos (kubectl apply)
- ✅ Pods health checks pasan
- ✅ Escalamiento automático funciona
- ✅ Red entre servicios correcta
- ✅ Políticas de red restrictivas
- ✅ Rolling update strategy definida
