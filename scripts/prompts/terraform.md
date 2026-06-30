# Reto: Terraform — Infraestructura como Código en AWS

Debes crear la configuración de Terraform para desplegar una infraestructura completa en AWS que incluya VPC, cómputo auto-escalable, base de datos RDS, balanceador de carga y almacenamiento S3.

## Arquitectura requerida

- **VPC** con CIDR 10.0.0.0/16, subnets públicas y privadas en 2 AZs
- **Internet Gateway** + **NAT Gateway**
- **Auto Scaling Group** con Launch Template (instancias en subnets privadas)
- **RDS PostgreSQL** con DB subnet group, cifrado, backup retention
- **ALB** con target group, health checks, listener HTTPS, redirección HTTP→HTTPS
- **S3 bucket** con versioning, bloqueo de acceso público, cifrado
- **IAM roles** para EC2, RDS, S3 con privilegios mínimos

## Archivos que debes crear

### `providers.tf`
Configuración del provider AWS y backend S3 para estado remoto con DynamoDB para state locking.

### `main.tf`
Todos los recursos de infraestructura.

### `variables.tf`
Variables tipadas con `type` y `description`.

### `outputs.tf`
Outputs útiles: ALB DNS, VPC ID, RDS endpoint, S3 bucket ARN.

### `terraform.tfvars.example`
Valores de ejemplo para las variables.

## Restricciones

- No uses recursos de pago innecesarios (usa free-tier donde sea posible)
- Todos los recursos deben tener tags consistentes
- Usa Terraform fmt consistente
- Sin valores hardcodeados: todo debe ser configurable mediante variables

## Criterios de evaluación (100 pts)

- Estructura y organización (15 pts): archivos separados, módulos, tfvars
- Estado remoto (10 pts): backend S3 + DynamoDB locking
- Red y conectividad (15 pts): VPC, subnets, IGW, NAT, routing
- Cómputo (10 pts): ASG con Launch Template, health checks
- Base de datos (10 pts): RDS PostgreSQL, cifrado, backups
- Almacenamiento (10 pts): S3 con versioning y cifrado
- Balanceo de carga (10 pts): ALB, target group, HTTPS
- Seguridad IAM (10 pts): roles con privilegios mínimos
- Buenas prácticas (10 pts): variables tipadas, outputs, tags

## Formato de salida

```hcl
# filepath: providers.tf
# ...
```

```hcl
# filepath: main.tf
# ...
```

```hcl
# filepath: variables.tf
# ...
```

```hcl
# filepath: outputs.tf
# ...
```

```hcl
# filepath: terraform.tfvars.example
# ...
```
