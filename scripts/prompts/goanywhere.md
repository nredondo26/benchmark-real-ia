# Reto: GoAnywhere MFT — Automatización de Transferencia de Archivos

Debes configurar un proyecto en GoAnywhere MFT (Managed File Transfer) que monitoree una carpeta, procese archivos CSV, los transforme y los envíe por SFTP a un servidor externo, con notificaciones, reintentos y logging completo.

## Tareas requeridas

1. **Monitoreo de carpeta** — El proyecto debe monitorear una carpeta local en busca de archivos CSV nuevos
2. **Validación de CSV** — Validar estructura del archivo antes de procesar (columnas, tipos, datos obligatorios)
3. **Transformación y SFTP** — Transformar los datos del CSV y enviarlos a un servidor SFTP externo con cifrado en tránsito
4. **Notificaciones por email** — Enviar notificación en éxito y en fallo con detalles del proceso
5. **Manejo de errores y reintentos** — Reintentar N veces antes de fallar definitivamente, con respaldo de archivo a carpeta de errores
6. **Logging** — Registrar todas las operaciones (inicio, archivos procesados, errores, éxito)
7. **Cifrado en reposo** — Los archivos procesados deben almacenarse cifrados

## Archivos que debes crear

### `project.xml`
Definición completa del proyecto GoAnywhere en formato XML con todas las tareas y recursos.

### `samples/clientes_import.csv`
Archivo CSV de ejemplo con la estructura esperada.

### `config.properties`
Archivo de propiedades con parámetros configurables (carpeta origen, destino SFTP, email remitente/destinatario, número de reintentos).

### `docs/README.md`
Documentación del proyecto explicando la configuración, dependencias y cómo desplegarlo.

## Restricciones

- No uses servicios externos que no sean el servidor SFTP y el servidor SMTP
- Todo debe ser configurable mediante propiedades
- Los datos sensibles (contraseñas, claves) deben referenciarse desde variables, no hardcodearse
- Soporta valores de ejemplo en config.properties

## Criterios de evaluación (100 pts)

- Monitoreo de carpeta (10 pts)
- Validación de CSV (20 pts)
- Transformación y SFTP (20 pts)
- Notificaciones por email (15 pts)
- Manejo de errores y reintentos (15 pts)
- Logging (10 pts)
- Configuración y seguridad (5 pts)
- Documentación (5 pts)

## Formato de salida

```xml
<!-- filepath: project.xml -->
<!-- ... -->
```

```csv
# filepath: samples/clientes_import.csv
# ...
```

```properties
# filepath: config.properties
# ...
```

```markdown
<!-- filepath: docs/README.md -->
<!-- ... -->
```
