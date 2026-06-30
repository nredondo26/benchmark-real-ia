# Especificación: Desarrollo ABAP y SAP

## Requisitos funcionales

### 1. Programa ABAP con ALV

- Crear un reporte Z `ZR_MATERIALES_ALV` que muestre una lista de materiales.
- Seleccionar datos de las tablas `MARA` (datos generales) y `MARC` (centro).
- Parámetros de selección: `MATNR` (rango), `WERKS` (centro), `MTART` (tipo material).
- Mostrar en ALV: `MATNR`, `MAKTX`, `MTART`, `MATKL`, `MEINS`, `WERKS`, `LGORT`, `DISPO`.
- El ALV debe soportar ordenamiento, filtro y descarga a Excel.
- Incluir botón para visualizar detalle del material seleccionado (popup con más campos).
- Manejar excepciones y mostrar mensajes de error amigables.

### 2. RFC Function Module para consulta de clientes

- Crear FM `Z_RFC_CONSULTA_CLIENTES` habilitado paraRemote.
- Parámetros de entrada: `IV_CLIENTE` (KUNNR, opcional), `IV_NOMBRE` (opcional).
- Parámetros de salida: `ET_CLIENTES` (tabla con KUNNR, NAME1, ORT01, STRAS, TELF1).
- Estructura de salida: `EZ_CLIENTE` con los mismos campos.
- Mensaje de retorno: `EV_MSG` con texto, `EV_TIPO` (S/E/W).
- Si no se encuentra el cliente, retornar mensaje de error.
- Incluir documentación en el FM (documentación de texto largo).

### 3. BAPI para creación de órdenes de venta

- Crear BAPI `Z_BAPI_CREA_ORDEN_VENTA` (método de objeto de negocio o FM con `BAPI` prefix).
- Parámetros: datos de cabecera (cliente, fecha, centro), datos de ítems (material, cantidad, precio).
- Llamar `BAPI_SALESORDER_CREATEFROMDAT2` internamente.
- Validar que el material exista y tenga stock.
- Retornar número de orden de venta (`VBELN`) y mensajes (tabla de retorno BAPI).
- Manejo de commit/rollback con `BAPI_TRANSACTION_COMMIT` / `ROLLBACK`.

### 4. Configuración de Idoc para intercambio EDI

- Crear tipo de Idoc Z `ZIDOC_PEDIDO_VENTA` basado en `ORDERS05`.
- Segmentos requeridos: `E1EDK01` (cabecera), `E1EDP01` (posiciones), `E1EDT01` (fechas).
- Crear partner profile para emisión/recepción.
- Configurar puerto y RFC destination.
- El Idoc debe generarse al crear una orden de venta vía BAPI (salida automática).
- Crear función de proceso de entrada: `Z_IDOC_INPUT_PEDIDO` usando `IDOC_INPUT_ORDERS`.

### 5. OData Service

- Crear servicio OData con SEGW: `ZPEDIDOS_VENTA_SRV`.
- Entity Set `PedidosSet` con propiedades: `Vbeln`, `Audat`, `Kunnr`, `Netwr`, `Waerk`.
- Entity Set `PosicionesSet` asociado a `PedidosSet` (navigation property).
- Implementar método `GET_ENTITY` y `GET_ENTITYSET` en `MPC_EXT` y `DPC_EXT`.
- Filtros: por `Vbeln`, `Kunnr` y rango de fechas (`Audat`).
- Probar con `/sap/opu/odata/sap/ZPEDIDOS_VENTA_SRV/PedidosSet`.

### 6. CDS View

- Crear CDS view `ZCDS_PEDIDOS_VENTA` con parámetros.
- Parámetros: `P_Vbeln` (tipo `Vbeln`), `P_Kunnr` (tipo `Kunnr`).
- Asociaciones: `_Cliente` a `KNA1`, `_Moneda` a `TCURC`.
- Campos: `Vbeln`, `Audat`, `Kunnr`, `Netwr`, `Waerk`, `Ernam`.
- La vista debe exponerse como analítica (con `@Analytics`).
- Agregar `@EndUserText.label` descriptivo.
