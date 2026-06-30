# Reto: Kubernetes — Despliegue de Aplicación

Debes crear los manifiestos YAML de Kubernetes para desplegar una aplicación multi-componente con alta disponibilidad, auto-escalado, almacenamiento persistente y políticas de red restrictivas.

## Arquitectura requerida

- **Namespace** propio (diferente de `default`)
- **2 Deployments** para diferentes componentes (ej: backend API y worker)
- **Service ClusterIP** para comunicación interna
- **Service LoadBalancer** para exposición externa
- **Ingress** con hostname, TLS mediante Secret, path-based routing
- **ConfigMap** y **Secrets** inyectados como variables de entorno
- **HPA** (Horizontal Pod Autoscaler) con target de CPU
- **PVC** con almacenamiento persistente
- **Network Policies** restrictivas
- **Liveness y Readiness Probes** en cada Deployment

## Archivos que debes crear

### `namespace.yaml`
Definición del namespace.

### `configmap.yaml` y `secret.yaml`
Configuración y datos sensibles (secret en base64).

### `deployment-backend.yaml` y `deployment-worker.yaml`
Deployments con: replicas ≥ 2, resource limits/requests, rolling update strategy, liveness/readiness probes, labels consistentes.

### `service-clusterip.yaml` y `service-loadbalancer.yaml`
Services para comunicación interna y externa.

### `ingress.yaml`
Ingress con hostname, TLS, path-based routing.

### `hpa.yaml`
HPA con target CPU, min/max réplicas.

### `pvc.yaml` y `pvc-claim.yaml`
PersistentVolumeClaim con ReadWriteOnce.

### `network-policy.yaml`
Política restrictiva de ingress con podSelector.

## Restricciones

- No uses `kind: Pod` directamente
- No dejes secrets en texto plano (usa base64)
- Todos los YAML deben ser válidos y formateados
- Todos los recursos deben incluir el namespace definido

## Criterios de evaluación (100 pts)

- Deployments (15 pts): resource limits, rolling update, replicas
- Services (10 pts): ClusterIP + LoadBalancer
- Ingress (10 pts): hostname, TLS, path-based routing
- ConfigMap y Secrets (10 pts)
- HPA (10 pts): target CPU, min/max réplicas
- PVC (10 pts): storage, modo de acceso
- Network Policies (10 pts): ingress restrictiva
- Liveness/Readiness Probes (10 pts)
- Namespace propio (10 pts)
- Buenas prácticas (5 pts): labels estándar, YAML formateado

## Formato de salida

```yaml
# filepath: namespace.yaml
# ...
```

(Repite para cada archivo YAML, usando siempre el path completo como comentario.)
