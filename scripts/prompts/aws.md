# Reto: AWS Serverless

Debes diseñar e implementar una arquitectura serverless en AWS usando API Gateway, Lambda, Step Functions, DynamoDB, SQS y S3, todo definido como infraestructura como código.

## Arquitectura requerida

- **API Gateway** REST o HTTP con autorizador Cognito en al menos un endpoint
- **Múltiples métodos HTTP**: GET, POST, DELETE
- **Mínimo 2 funciones Lambda** independientes con variables de entorno
- **Una función Lambda disparada por evento** (SQS, EventBridge o S3)
- **Step Functions** workflow coordinando ≥ 2 Lambdas con manejo de errores (Retry, Catch) y uso de Choice/Wait/Parallel
- **DynamoDB** con clave de partición y GSI o LSI
- **SQS** con Dead Letter Queue (DLQ) y política de acceso para Lambda
- **S3 bucket** con cifrado, notificaciones de eventos y lifecycle policy
- **CloudWatch** alarmas para errores de Lambda y longitud de cola SQS

## Archivos que debes crear

### `template.yaml` o `cdk/app.py` o `main.tf`
Infraestructura como código completa (SAM, CDK o Terraform). Incluye parámetros/variables y outputs con URLs y ARNs.

### `lambdas/process_order.py`
Función Lambda de ejemplo con logging estructurado y timeout < 1 minuto.

### `lambdas/send_notification.py`
Segunda función Lambda con logging estructurado.

## Restricciones

- No uses EC2 ni servidores tradicionales
- Todas las funciones Lambda deben incluir logging estructurado
- Usa variables de entorno para configuraciones sensibles
- Permisos IAM con privilegios mínimos

## Criterios de evaluación (100 pts)

- API Gateway + Cognito (15 pts): autorizador, múltiples métodos
- Funciones Lambda (15 pts): 2+ funciones, variables de entorno, IAM mínimo, una disparada por evento
- Step Functions (15 pts): workflow, manejo de errores, Choice/Wait/Parallel
- DynamoDB (10 pts): clave partición, GSI/LSI, capacidad
- SQS (10 pts): cola, DLQ, política de acceso
- S3 (10 pts): cifrado, notificaciones, lifecycle
- CloudWatch (10 pts): alarmas Lambda y SQS
- Infraestructura como Código (10 pts): CDK/SAM/Terraform, parámetros, outputs
- Buenas prácticas (5 pts): logging, timeout, sin EC2

## Formato de salida

```python
# filepath: lambdas/process_order.py
# ...
```

```python
# filepath: lambdas/send_notification.py
# ...
```

```yaml
# filepath: template.yaml
# ...
```
