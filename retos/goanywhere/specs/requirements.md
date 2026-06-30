# Especificación: Automatización MFT con GoAnywhere

## Requisitos funcionales

### 1. Monitoreo de carpeta

- El proyecto debe monitorear una carpeta local (`/incoming`) en busca de archivos CSV.
- Cuando un archivo nuevo llegue, debe detectarse automáticamente.
- El archivo debe moverse a una carpeta `/processing` mientras se procesa.
- Al finalizar (éxito o error), moverse a `/processed` o `/error` respectivamente.

### 2. Validación de estructura CSV

- El archivo CSV debe tener exactamente las columnas: `id_cliente, nombre, monto, fecha, email`.
- Validar que no haya filas vacías.
- Validar que `monto` sea numérico y positivo.
- Validar que `fecha` tenga formato `YYYY-MM-DD`.
- Validar que `email` tenga formato válido.
- Si hay errores de validación, registrar cada error y rechazar el archivo completo.

### 3. Transformación y envío SFTP

- Transformar el CSV eliminando espacios en blanco al inicio/fin de cada campo.
- Agregar columna `procesado_en` con timestamp del momento del envío.
- Conectar a servidor SFTP externo (host, puerto, usuario, clave privada o password).
- Subir archivo transformado a carpeta `/outgoing` del SFTP remoto.
- El nombre del archivo remoto debe ser `ingestion_AAAAMMDD_HHMMSS.csv`.
- Verificar checksum (SHA-256) del archivo transferido.

### 4. Notificaciones por email

- Enviar email de éxito: asunto "Ingesta exitosa — {nombre_archivo}", cuerpo con resumen (total registros, fecha proceso).
- Enviar email de fallo: asunto "Error en ingesta — {nombre_archivo}", cuerpo con descripción del error.
- Usar servidor SMTP configurable (host, puerto, TLS, credenciales).
- Los destinatarios deben ser configurables.

### 5. Manejo de errores con reintentos

- Si el SFTP falla, reintentar hasta 3 veces con backoff exponencial (30s, 60s, 120s).
- Si el email falla, reintentar 2 veces con backoff de 15s.
- Si el CSV está malformado (no se puede parsear), rechazar sin reintentar.
- Registrar cada reintento en el log.

### 6. Logging

- Usar log4j o el logger nativo de GoAnywhere.
- Cada operación debe tener nivel: INFO, WARN o ERROR.
- Formato: `[YYYY-MM-DD HH:mm:ss] [NIVEL] [PROCESO] mensaje`.
- Eventos a loggear: inicio de proceso, validación (éxito/fallo), conexión SFTP, transferencia, email enviado, reintentos.
- Los logs deben rotar semanalmente y conservarse 30 días.
