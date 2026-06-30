# Reto: SAP — Programas ABAP e Integraciones

Debes desarrollar un conjunto de programas ABAP e integraciones para un sistema SAP que incluyen reportes ALV, RFC, BAPI, Idoc, OData y CDS views.

## Tareas requeridas

1. **Programa ABAP con ALV** — Reporte de materiales con salida ALV, selección por almacén y tipo de material, ordenamiento y filtros interactivos
2. **RFC Function Module** — Módulo de función RFC para consulta de clientes por rango de fechas, con estructura de entrada/salida y manejo de errores
3. **BAPI para órdenes de venta** — BAPI que crea órdenes de venta con validaciones, commit/rollback controlado y mensajes de retorno
4. **Configuración de Idoc** — Idoc para intercambio EDI con estructura de segmentos y configuración de puerto
5. **OData Service** — Servicio OData para consultar datos de materiales desde sistemas externos con filtros y paginación
6. **CDS View** — Vista CDS con parámetros, asociaciones a otras tablas y optimizada para rendimiento

## Archivos que debes crear

### `zreport_materiales.abap`
Programa ABAP con ALV para reporte de materiales usando ALV Grid (clase CL_GUI_ALV_GRID o función REUSE_ALV_GRID_DISPLAY).

### `zrfc_consulta_clientes.abap`
RFC Function Module para consulta de clientes con estructura de exportación/importación.

### `zbapi_crear_ov.abap`
BAPI para creación de órdenes de venta con BAPI_SALESORDER_CREATEFROMDAT2.

### `zidoc_config.txt`
Configuración de Idoc con definición de segmentos, puerto y partner profile.

### `zsrv_materiales_odata.abap`
Implementación de OData service usando clase CL_SADL_GTK_EXPOSURE o similar.

### `zcds_view_materiales.abap`
CDS view con anotaciones, parámetros y asociaciones.

## Restricciones

- El código ABAP debe ser sintácticamente válido
- Sigue las convenciones de nomenclatura SAP (Z para objetos personalizados)
- No uses objetos inexistentes en SAP estándar
- Documenta cada programa con cabecera de autor, fecha, propósito

## Criterios de evaluación (100 pts)

- Programa ABAP con ALV (20 pts): selección, salida, interactividad
- RFC Function Module (15 pts): estructura, parámetros, errores
- BAPI para órdenes de venta (20 pts): creación, validaciones, commit/rollback
- Configuración de Idoc (15 pts): segmentos, puerto, partner profile
- OData Service (15 pts): filtros, paginación, retorno de datos
- CDS View (10 pts): parámetros, asociaciones, rendimiento
- Calidad del código y convenciones (5 pts)

## Formato de salida

```abap
" filepath: zreport_materiales.abap
" ...
```

(Repite para cada archivo ABAP con la ruta completa como comentario.)

```text
" filepath: zidoc_config.txt
" ...
```
