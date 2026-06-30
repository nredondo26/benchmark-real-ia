# Checklist de Verificación — SAP

## Programa ABAP ALV

- [ ] El reporte `ZR_MATERIALES_ALV` compila sin errores de sintaxis
- [ ] Los parámetros de selección funcionan (MATNR, WERKS, MTART)
- [ ] El ALV se muestra correctamente con las columnas especificadas
- [ ] Soporta ordenamiento por columna
- [ ] Soporta filtros en cada columna
- [ ] Permite descarga a Excel
- [ ] El botón de detalle muestra popup con información del material
- [ ] Los mensajes de error se muestran correctamente

## RFC Function Module

- [ ] `Z_RFC_CONSULTA_CLIENTES` está habilitado para Remote Call
- [ ] Parámetros de entrada y salida coinciden con la especificación
- [ ] Retorna datos correctos para un KUNNR existente
- [ ] Retorna mensaje de error para un KUNNR inexistente
- [ ] La búsqueda por nombre funciona parcialmente
- [ ] Incluye documentación de texto largo

## BAPI para órdenes de venta

- [ ] `Z_BAPI_CREA_ORDEN_VENTA` existe como FM o método BAPI
- [ ] Crea orden de venta exitosamente con datos válidos
- [ ] Valida existencia del material
- [ ] Valida disponibilidad de stock
- [ ] Retorna número de orden de venta (VBELN)
- [ ] Retorna mensajes BAPI de error en caso de fallo
- [ ] Usa BAPI_TRANSACTION_COMMIT y ROLLBACK apropiadamente

## Idoc EDI

- [ ] Tipo de Idoc Z `ZIDOC_PEDIDO_VENTA` creado
- [ ] Segmentos E1EDK01, E1EDP01, E1EDT01 incluidos
- [ ] Partner profile configurado
- [ ] Puerto y RFC destination configurados
- [ ] La salida automática se dispara al crear orden de venta
- [ ] Función de entrada `Z_IDOC_INPUT_PEDIDO` implementada

## OData Service

- [ ] Servicio `ZPEDIDOS_VENTA_SRV` creado en SEGW
- [ ] Entity Sets `PedidosSet` y `PosicionesSet` definidos
- [ ] Navigation property entre Pedidos y Posiciones
- [ ] `GET_ENTITY` retorna un pedido por VBELN
- [ ] `GET_ENTITYSET` retorna lista filtrable
- [ ] Filtros por VBELN, KUNNR y rango de fechas funcionan
- [ ] El servicio responde correctamente desde `/sap/opu/odata/...`

## CDS View

- [ ] `ZCDS_PEDIDOS_VENTA` se activa sin errores
- [ ] Parámetros `P_Vbeln` y `P_Kunnr` funcionan
- [ ] Asociaciones `_Cliente` y `_Moneda` resuelven correctamente
- [ ] Campos expuestos según especificación
- [ ] Anotación `@Analytics` presente
- [ ] Label descriptivo con `@EndUserText.label`

## Calidad general

- [ ] Todos los objetos Z siguen convenciones de nomenclatura SAP
- [ ] El código contiene comentarios explicativos donde es necesario
- [ ] No hay transacciones abiertas sin commit/rollback
- [ ] Manejo de excepciones y mensajes de error en todos los objetos

## Puntuación (100 pts)

| Criterio | Pts |
|----------|-----|
| Programa ABAP con ALV | 20 |
| RFC Function Module | 15 |
| BAPI para órdenes de venta | 20 |
| Configuración de Idoc | 15 |
| OData Service | 15 |
| CDS View | 10 |
| Calidad del código y convenciones | 5 |
