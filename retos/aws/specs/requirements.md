# Reto: Arquitectura Serverless en AWS

## Objetivo
Diseñar e implementar una arquitectura serverless completa usando CDK, SAM o Terraform, integrando múltiples servicios de AWS sin servidores gestionados.

## Requerimientos Obligatorios

### 1. API Gateway + Cognito
- API Gateway REST o HTTP API
- Integración con Lambda (proxy integration)
- Autorizador Cognito (Cognito User Pool) en al menos un endpoint
- Endpoints con métodos GET, POST, DELETE
- Modelos de solicitud/respuesta (si aplica)

### 2. Funciones Lambda
- Al menos 2 funciones Lambda independientes
- Runtime moderno (Python 3.12+, Node.js 20+, Go, etc.)
- Variables de entorno para configuración
- Permisos IAM mínimos para cada función (principle of least privilege)
- Una función disparada por API Gateway, otra por SQS o EventBridge

### 3. Step Functions
- Workflow de Step Functions que coordina al menos 2 Lambdas
- Manejo de errores (retry, catch)
- Tipos de estado: Task, Choice, Wait o Parallel
- Input/output processing

### 4. DynamoDB
- Tabla DynamoDB con clave de partición y/o clave de ordenación
- Modo de capacidad bajo demanda (on-demand) o provisionada
- Índice secundario global (GSI) o local (LSI)

### 5. SQS
- Cola SQS (estándar o FIFO)
- Dead Letter Queue (DLQ) configurada
- Política de acceso que permita a Lambda leer mensajes

### 6. S3
- Bucket S3 para almacenamiento de archivos (imágenes, documentos, etc.)
- Notificaciones de eventos S3 → Lambda o SQS
- Cifrado del lado del servidor
- Política de ciclo de vida (lifecycle policy)

### 7. CloudWatch
- Alarma CloudWatch para errores de Lambda (ej. tasa de errores > 5%)
- Alarma para longitud de cola SQS (ej. > 100 mensajes)
- Dashboard con métricas clave (opcional pero valorado)

### 8. Infraestructura como Código
- Todo definido con CDK (TypeScript/Python), SAM o Terraform
- Variables de entorno o parámetros para configuración
- Outputs con URLs, ARNs y valores relevantes

## Entregables
- Código fuente completo (app + infraestructura)
- Archivo `README.md` con instrucciones de deploy
- Script de prueba (invocar API endpoints)

## Restricciones
- No usar EC2 ni servidores tradicionales
- Todas las Lambdas deben tener menos de 1 minuto de timeout
- Las funciones deben tener logging estructurado (CloudWatch)
- Uso obligatorio de variables de entorno para configuraciones sensibles
