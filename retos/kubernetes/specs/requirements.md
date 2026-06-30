# Reto: Orquestación con Kubernetes

## Objetivo
Desplegar una aplicación completa en Kubernetes con todos los manifiestos YAML necesarios, aplicando buenas prácticas de seguridad, escalabilidad y gestión de configuración.

## Requerimientos Obligatorios

### 1. Deployments
- Mínimo 2 Deployments para diferentes componentes (ej. frontend + backend)
- Resource limits y requests definidos (CPU y memoria)
- Estrategia de actualización (RollingUpdate)
- Replicas iniciales ≥ 2
- Selectors y labels consistentes

### 2. Services
- Service tipo **ClusterIP** para comunicación interna
- Service tipo **LoadBalancer** para exposición externa
- Selectors correctamente alineados con los Pods

### 3. Ingress con TLS
- Recurso Ingress con hostname definido
- TLS configurado con un Secret
- Reglas de ruteo (path-based routing)

### 4. ConfigMap y Secrets
- ConfigMap para variables de configuración no sensibles
- Secret para datos sensibles (credenciales, API keys)
- Ambos inyectados como variables de entorno y/o volúmenes

### 5. Horizontal Pod Autoscaler (HPA)
- HPA configurado para al menos un Deployment
- Métrica basada en CPU (target average utilization)
- Mínimo y máximo de réplicas definido

### 6. Persistent Volume Claim (PVC)
- PVC solicitando almacenamiento (ej. 1Gi)
- Modo de acceso ReadWriteOnce
- Referenciado por al menos un Deployment

### 7. Network Policies
- Política que restrinja tráfico entrante (ingress) solo desde componentes autorizados
- Política que restrinja tráfico saliente (egress) si aplica
- Uso de podSelector y namespaceSelector

### 8. Liveness y Readiness Probes
- Liveness probe en cada Deployment (HTTP, TCP o command)
- Readiness probe en cada Deployment
- Parámetros: initialDelaySeconds, periodSeconds, timeoutSeconds

### 9. Namespace
- Todos los recursos deben estar en un namespace específico (no `default`)
- Namespace definido al inicio de cada manifiesto

## Entregables
- Archivos YAML separados por recurso o en un solo `deployment.yaml` organizado con `---`
- Preferiblemente una carpeta `k8s/` con los manifiestos

## Restricciones
- No usar `kind: Pod` directamente (usar Deployments)
- No usar `imagePullPolicy: Always` sin justificación
- Los Secrets deben estar codificados en base64 (no en texto plano literal)
- Todos los recursos deben tener labels: `app`, `environment`, `managed-by`
