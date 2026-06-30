# Checklist de Verificación — GoAnywhere MFT

## Configuración del proyecto

- [ ] El proyecto GoAnywhere está creado y configurado
- [ ] Las carpetas `/incoming`, `/processing`, `/processed`, `/error` existen
- [ ] Los recursos (conexión SFTP, SMTP) están definidos
- [ ] Los certificados y credenciales están configurados de forma segura

## Monitoreo de carpeta

- [ ] El proyecto detecta automáticamente un archivo CSV nuevo en `/incoming`
- [ ] El archivo se mueve a `/processing` durante el procesamiento
- [ ] Al terminar con éxito, se mueve a `/processed`
- [ ] Al terminar con error, se mueve a `/error`

## Validación de estructura CSV

- [ ] Rechaza archivos con columnas faltantes
- [ ] Rechaza filas vacías
- [ ] Rechaza montos no numéricos o negativos
- [ ] Rechaza fechas con formato incorrecto
- [ ] Rechaza emails inválidos
- [ ] Rechaza el archivo completo si hay errores
- [ ] Un CSV válido pasa todas las validaciones

## Transformación y SFTP

- [ ] Se eliminan espacios en blanco al inicio/fin de campos
- [ ] Se agrega columna `procesado_en` con timestamp
- [ ] La conexión SFTP se establece correctamente
- [ ] El archivo se sube a la carpeta remota `/outgoing`
- [ ] El nombre remoto sigue el patrón `ingestion_AAAAMMDD_HHMMSS.csv`
- [ ] El checksum SHA-256 se verifica

## Notificaciones por email

- [ ] Se envía email de éxito con resumen de registros
- [ ] Se envía email de fallo con descripción del error
- [ ] Los destinatarios son los configurados
- [ ] El email se envía vía SMTP con TLS

## Reintentos

- [ ] Reintenta SFTP hasta 3 veces con backoff exponencial
- [ ] Reintenta email hasta 2 veces con backoff de 15s
- [ ] CSV malformado se rechaza sin reintento
- [ ] Los reintentos quedan registrados en el log

## Logging

- [ ] Formato correcto: `[YYYY-MM-DD HH:mm:ss] [NIVEL] [PROCESO]`
- [ ] Eventos de inicio, validación, SFTP, email y reintentos están logueados
- [ ] Uso de niveles INFO, WARN y ERROR apropiados
- [ ] Rotación semanal y retención de 30 días configurada

## Puntuación (100 pts)

| Criterio | Pts |
|----------|-----|
| Monitoreo de carpeta | 10 |
| Validación de CSV | 20 |
| Transformación y SFTP | 20 |
| Notificaciones por email | 15 |
| Manejo de errores y reintentos | 15 |
| Logging | 10 |
| Configuración y seguridad | 5 |
| Documentación | 5 |
