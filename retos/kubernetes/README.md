# Reto Kubernetes — Criterios de Evaluación

## Puntaje total: 100 puntos

### 1. Deployments (15 pts)
| Criterio | Pts |
|---|---|
| Mínimo 2 Deployments para diferentes componentes | 4 |
| Resource limits y requests (CPU + memoria) | 4 |
| Estrategia RollingUpdate configurada | 3 |
| Replicas ≥ 2 y labels consistentes | 4 |

### 2. Services (10 pts)
| Criterio | Pts |
|---|---|
| Service ClusterIP para comunicación interna | 5 |
| Service LoadBalancer para exposición externa | 5 |

### 3. Ingress (10 pts)
| Criterio | Pts |
|---|---|
| Recurso Ingress con hostname definido | 4 |
| TLS configurado mediante Secret | 3 |
| Path-based routing implementado | 3 |

### 4. ConfigMap y Secrets (10 pts)
| Criterio | Pts |
|---|---|
| ConfigMap inyectado como env o volumen | 5 |
| Secret con datos codificados en base64 | 5 |

### 5. HPA (10 pts)
| Criterio | Pts |
|---|---|
| HPA configurado correctamente | 4 |
| Target CPU definido | 3 |
| Mínimo y máximo de réplicas | 3 |

### 6. PVC (10 pts)
| Criterio | Pts |
|---|---|
| PVC con storage solicitado | 5 |
| Modo de acceso ReadWriteOnce | 2 |
| Referenciado por un Deployment | 3 |

### 7. Network Policies (10 pts)
| Criterio | Pts |
|---|---|
| Política restrictiva de ingress | 5 |
| Uso de podSelector y/o namespaceSelector | 5 |

### 8. Liveness y Readiness Probes (10 pts)
| Criterio | Pts |
|---|---|
| Liveness probe en cada Deployment | 5 |
| Readiness probe en cada Deployment | 5 |

### 9. Namespace y Organización (10 pts)
| Criterio | Pts |
|---|---|
| Namespace definido (diferente de `default`) | 5 |
| Namespace presente en metadata de cada recurso | 5 |

### 10. Buenas Prácticas (5 pts)
| Criterio | Pts |
|---|---|
| Labels estándar (`app`, `environment`, `managed-by`) | 2 |
| YAML válido y formateado | 3 |

---

## Penalizaciones
- **-10 pts**: Secrets en texto plano (no base64)
- **-10 pts**: Usa `kind: Pod` directamente
- **-5 pts**: Namespace `default` sin justificación
- **-5 pts**: Faltan resource limits/requests
