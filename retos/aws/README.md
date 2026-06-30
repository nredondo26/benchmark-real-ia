# Reto AWS Serverless — Criterios de Evaluación

## Puntaje total: 100 puntos

### 1. API Gateway + Cognito (15 pts)
| Criterio | Pts |
|---|---|
| API Gateway REST o HTTP configurado | 5 |
| Autorizador Cognito integrado en al menos un endpoint | 5 |
| Múltiples métodos HTTP (GET, POST, DELETE) | 5 |

### 2. Funciones Lambda (15 pts)
| Criterio | Pts |
|---|---|
| Mínimo 2 funciones Lambda independientes | 5 |
| Variables de entorno para configuración | 3 |
| Permisos IAM con privilegios mínimos | 4 |
| Una función disparada por evento (SQS/EventBridge/S3) | 3 |

### 3. Step Functions (15 pts)
| Criterio | Pts |
|---|---|
| Workflow coordinando ≥ 2 Lambdas | 6 |
| Manejo de errores (Retry, Catch) | 5 |
| Uso de Choice, Wait o Parallel | 4 |

### 4. DynamoDB (10 pts)
| Criterio | Pts |
|---|---|
| Tabla con clave de partición y/o ordenación | 4 |
| GSI o LSI definido | 3 |
| Capacidad on-demand o provisionada | 3 |

### 5. SQS (10 pts)
| Criterio | Pts |
|---|---|
| Cola SQS definida | 4 |
| Dead Letter Queue (DLQ) configurada | 3 |
| Política de acceso para Lambda | 3 |

### 6. S3 (10 pts)
| Criterio | Pts |
|---|---|
| Bucket S3 con cifrado | 4 |
| Notificaciones de eventos (S3 → Lambda/SQS) | 3 |
| Lifecycle policy configurada | 3 |

### 7. CloudWatch (10 pts)
| Criterio | Pts |
|---|---|
| Alarma para errores de Lambda | 4 |
| Alarma para longitud de cola SQS | 3 |
| Dashboard de métricas (opcional pero bonifica) | 3 |

### 8. Infraestructura como Código (10 pts)
| Criterio | Pts |
|---|---|
| Uso de CDK, SAM o Terraform | 4 |
| Parámetros/variables para configuración | 3 |
| Outputs con URLs y ARNs | 3 |

### 9. Buenas Prácticas (5 pts)
| Criterio | Pts |
|---|---|
| Logging estructurado en Lambdas | 2 |
| Timeout de Lambdas < 1 minuto | 1 |
| Sin recursos EC2 | 2 |

---

## Penalizaciones
- **-15 pts**: Usa EC2 o servidores tradicionales
- **-10 pts**: Funciones Lambda sin logging
- **-5 pts**: No usa variables de entorno para config sensibles
- **-5 pts**: Falta manejo de errores en Step Functions
