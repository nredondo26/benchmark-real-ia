# Reto: AWS

## Objetivo

Diseñar e implementar una arquitectura serverless en AWS.

## Componentes

- API Gateway con autenticación Cognito
- Lambda functions (Python/Node/Go) para lógica de negocio
- Step Functions para orchestrar flujo multi-paso
- DynamoDB como base de datos principal
- SQS para manejo de tareas asíncronas
- S3 para almacenamiento de archivos
- CloudWatch para monitoreo y alertas

## Criterios de evaluación

- ✅ Arquitectura completa con AWS CDK / SAM / Terraform
- ✅ Lambdas se ejecutan sin errores
- ✅ Step Functions orquestan flujo correctamente
- ✅ Manejo de errores y retry en SQS
- ✅ Permisos IAM con mínimo privilegio
- ✅ Costos estimados documentados
