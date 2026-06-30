# Reto: Terraform

## Objetivo

Crear infraestructura como código en AWS usando Terraform.

## Recursos a crear

- VPC con subnets públicas y privadas
- EC2 instance con auto-scaling group
- RDS (PostgreSQL) en subnet privada
- S3 bucket para backups con versioning
- Application Load Balancer con HTTPS
- IAM roles con principio de mínimo privilegio

## Requisitos

- Módulos reutilizables
- Outputs y variables tipadas
- Remote state en S3 + DynamoDB locking
- Tags consistentes en todos los recursos

## Criterios de evaluación

- ✅ `terraform plan` exitoso
- ✅ `terraform apply` crea todos los recursos
- ✅ Módulos bien estructurados
- ✅ Seguridad (no secrets en código, puertos restringidos)
- ✅ Documentación de cada módulo
