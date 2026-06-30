# Reto: Infraestructura como Código con Terraform

## Objetivo
Crear una infraestructura completa en AWS usando Terraform, siguiendo las mejores prácticas de modularización, seguridad y estado remoto.

## Requerimientos Obligatorios

### 1. Estado Remoto
- Backend S3 para el estado de Terraform
- DynamoDB para bloqueo de estado (state locking)
- Bucket S3 con versioning habilitado

### 2. Red (VPC)
- Una VPC con direccionamiento CIDR personalizado
- Subnets públicas (al menos 2) distribuidas en diferentes AZs
- Subnets privadas (al menos 2) distribuidas en diferentes AZs
- Internet Gateway para subnets públicas
- NAT Gateway(s) para subnets privadas
- Tablas de enrutamiento correctamente asociadas

### 3. Cómputo (EC2 con ASG)
- Un Auto Scaling Group (ASG) usando Launch Template
- Instancias EC2 en subnets privadas
- User data o script de bootstrap
- Health checks configurados

### 4. Base de Datos (RDS PostgreSQL)
- Instancia RDS PostgreSQL en subnets privadas
- Grupo de subnets (DB subnet group)
- Almacenamiento cifrado (encrypted)
- Backup retention configurado
- Grupo de seguridad restringido

### 5. Almacenamiento (S3)
- Bucket S3 con versioning habilitado
- Bloqueo de acceso público (public access block)
- Cifrado del lado del servidor (SSE-S3 o SSE-KMS)

### 6. Balanceo de Carga (ALB con HTTPS)
- Application Load Balancer interno o面向 Internet
- Target group con health checks
- Listener en HTTPS (puerto 443)
- Listener en HTTP (puerto 80) con redirección a HTTPS

### 7. Seguridad (IAM)
- Roles IAM con privilegios mínimos (least privilege)
- Políticas específicas para cada servicio (EC2, RDS, S3)
- Separación de responsabilidades

### 8. Modularización
- Uso de módulos de Terraform (pueden ser locales o del Registry)
- Variables tipadas con descripciones
- Outputs definidos para valores clave
- Archivos `variables.tf`, `outputs.tf`, `main.tf` separados

## Entregables
- Código Terraform completo y documentado
- Archivo `terraform.tfvars` de ejemplo (sin valores sensibles reales)
- Script de deploy/cleanup (opcional)

## Restricciones
- No usar recursos de tipo `aws_instance` directamente (usar ASG + LT)
- Todas las variables deben tener tipo definido y descripción
- Todos los recursos deben tener tags: `Proyecto`, `Ambiente`, `CreadoPor`
