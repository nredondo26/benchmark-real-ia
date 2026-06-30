# Reto Terraform — Criterios de Evaluación

## Puntaje total: 100 puntos

### 1. Estructura y Organización del Código (15 pts)
| Criterio | Pts |
|---|---|
| Archivos separados: `main.tf`, `variables.tf`, `outputs.tf`, `providers.tf` | 5 |
| Uso de módulos (locales o del Registry) | 5 |
| Archivo `terraform.tfvars.example` con valores de ejemplo | 5 |

### 2. Estado Remoto (10 pts)
| Criterio | Pts |
|---|---|
| Backend S3 configurado correctamente | 5 |
| DynamoDB para state locking | 5 |

### 3. Red y Conectividad (15 pts)
| Criterio | Pts |
|---|---|
| VPC con CIDR adecuado | 3 |
| Subnets públicas (mín. 2 en distintas AZs) | 3 |
| Subnets privadas (mín. 2 en distintas AZs) | 3 |
| Internet Gateway + NAT Gateway | 4 |
| Tablas de enrutamiento correctas | 2 |

### 4. Cómputo (10 pts)
| Criterio | Pts |
|---|---|
| Auto Scaling Group con Launch Template | 5 |
| Instancias en subnets privadas | 3 |
| Health checks configurados | 2 |

### 5. Base de Datos (10 pts)
| Criterio | Pts |
|---|---|
| RDS PostgreSQL con DB subnet group | 4 |
| Almacenamiento cifrado (encrypted = true) | 3 |
| Backup retention configurado | 3 |

### 6. Almacenamiento (10 pts)
| Criterio | Pts |
|---|---|
| Bucket S3 con versioning | 5 |
| Bloqueo de acceso público + cifrado | 5 |

### 7. Balanceo de Carga (10 pts)
| Criterio | Pts |
|---|---|
| ALB con target group y health checks | 4 |
| Listener HTTPS | 3 |
| Redirección HTTP → HTTPS | 3 |

### 8. Seguridad IAM (10 pts)
| Criterio | Pts |
|---|---|
| Roles IAM para EC2, RDS, S3 | 5 |
| Políticas con privilegios mínimos | 5 |

### 9. Buenas Prácticas (10 pts)
| Criterio | Pts |
|---|---|
| Variables tipadas con `type` y `description` | 4 |
| Outputs con valores útiles (ALB DNS, VPC ID, etc.) | 3 |
| Tags consistentes en todos los recursos | 3 |

---

## Penalizaciones
- **-10 pts**: No usa Terraform fmt consistente
- **-5 pts**: Variables sin tipo definido
- **-10 pts**: Recursos hardcodeados sin variables
- **-15 pts**: No usa estado remoto
