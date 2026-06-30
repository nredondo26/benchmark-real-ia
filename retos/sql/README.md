# Reto: Optimización SQL

## Objetivo

Optimizar 5 queries lentas y corregir malas prácticas de modelado en un esquema de e-commerce.

## Esquema

El sistema modela 7 tablas para un e-commerce:

| Tabla         | Descripción                          |
|---------------|--------------------------------------|
| `categories`  | Jerarquía de categorías (con padre)  |
| `products`    | Catálogo de 100 productos            |
| `customers`   | 50 clientes registrados              |
| `orders`      | 200 órdenes de compra                |
| `order_items` | Detalle de productos por orden       |
| `payments`    | Pagos asociados a órdenes            |
| `reviews`     | Opiniones de clientes sobre productos|

## Datos de ejemplo

- **100 productos** en 10 categorías (electrónica, ropa, hogar, deportes)
- **50 clientes** con datos de contacto
- **200 órdenes** con estados: `pendiente`, `enviado`, `pagado`, `entregado`
- **Aprox. 500 items** en order_items (3-4 por orden)
- **35 reviews** con calificaciones y comentarios
- **200 pagos** asociados a las órdenes

## Malas prácticas incluidas (debes corregirlas)

1. **Sin índice en FK**: `products.category_id` no tiene índice
2. **VARCHAR para fechas**: `orders.order_date` es `VARCHAR(10)` en vez de `DATE`
3. **FK faltante**: `order_items.order_id` no tiene `REFERENCES orders(id)`
4. **TEXT para fechas**: `reviews.review_date` es `TEXT` en vez de `DATE`
5. **Sin índice en FK**: `orders.customer_id` no tiene índice

## Las 5 queries lentas

### Query 1: Full table scan
Usa `YEAR()` sobre `created_at` impidiendo el uso de índices.

### Query 2: N+1 disfrazado
Subconsultas correlacionadas para obtener nombre y email del cliente.

### Query 3: LIKE '%term%'
Búsqueda textual con comodín izquierdo sobre columna sin índice.

### Query 4: Subconsultas correlacionadas
Calcula total_orders, total_spent, max_order por cliente con 4 subconsultas.

### Query 5: ORDER BY sin índice + funciones
Ordena por `total DESC` sin índice y usa `SUBSTR`/`CAST` en ORDER BY.

## Optimización esperada

1. Agregar índices faltantes (category_id, customer_id, order_date, total)
2. Cambiar tipos de datos: VARCHAR → DATE, TEXT → DATE
3. Agregar FK constraint faltante en order_items
4. Reescribir queries usando JOIN, GROUP BY, rangos de fechas
5. Crear índices compuestos para ORDER BY y filtros comunes

## Scoring

| Criterio                          | Puntos |
|-----------------------------------|--------|
| Índices agregados correctamente   | 20     |
| Tipos de datos corregidos         | 10     |
| FK constraint agregado            | 10     |
| Query 1 optimizada                | 15     |
| Query 2 optimizada                | 15     |
| Query 3 optimizada                | 15     |
| Query 4 optimizada                | 15     |
| Query 5 optimizada                | 15     |
| Migración sin errores             | 10     |
| **Total**                         | **125**|

## Cómo ejecutar

```bash
# 1. Crear BD y cargar esquema
sqlite3 ecommerce.db < schema.sql

# 2. Insertar datos
sqlite3 ecommerce.db < seed.sql

# 3. Verificar estado inicial
sqlite3 ecommerce.db < tests/verify.sql

# 4. Aplicar optimizaciones (tú escribes esto)
# ... crea migrate.sql con ALTER TABLE, CREATE INDEX, etc.

# 5. Verificar optimizaciones
sqlite3 ecommerce.db < tests/verify.sql
```

## Entregables

- `migrate.sql` — Script con las correcciones al esquema
- `optimized_queries.sql` — Las 5 queries reescritas
- `report.sql` — (Opcional) Reporte de ventas por mes/categoría
