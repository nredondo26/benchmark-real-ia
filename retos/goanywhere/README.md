# Reto: GoAnywhere MFT

## Objetivo

Configurar automatización de transferencia de archivos con GoAnywhere MFT.

## Tareas

- Crear un proyecto que monitoree una carpeta y procese archivos CSV
- Validar estructura del archivo antes de procesar
- Transformar y enviar a SFTP externo
- Enviar notificación por email en éxito/fallo
- Manejo de errores con reintentos
- Logging de todas las operaciones

## Criterios de evaluación

- ✅ Proyecto funcional en GoAnywhere
- ✅ Validación de datos implementada
- ✅ Encriptación en tránsito y reposo
- ✅ Notificaciones funcionan
- ✅ Logging completo

## Puntuación

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
| **Total** | **100** |

## Referencias

- [Especificación detallada](specs/requirements.md)
- [Checklist de verificación](tests/checklist.md)
