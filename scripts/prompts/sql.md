# Reto: Optimización SQL — E-commerce

Debes optimizar 5 queries lentas y corregir malas prácticas de modelado en un esquema SQLite de e-commerce.

## Esquema actual (7 tablas)

- `categories` — Jerarquía de categorías (con padre)
- `products` — Catálogo de 100 productos
- `customers` — 50 clientes
- `orders` — 200 órdenes (order_date como VARCHAR(10))
- `order_items` — ~500 items (sin FK a orders)
- `payments` — 200 pagos
- `reviews` — 35 reviews (review_date como TEXT)

## Malas prácticas a corregir

1. `products.category_id` sin índice
2. `orders.order_date` es VARCHAR(10) en vez de DATE
3. `order_items.order_id` no tiene REFERENCES orders(id)
4. `reviews.review_date` es TEXT en vez de DATE
5. `orders.customer_id` sin índice

## Queries lentas a optimizar

1. Usa `YEAR()` sobre `created_at` impidiendo uso de índices
2. Subconsultas correlacionadas para obtener nombre y email del cliente
3. Búsqueda con `LIKE '%termino%'` en columna sin índice
4. Calcula total_orders, total_spent, max_order con 4 subconsultas
5. ORDER BY total DESC sin índice, usa SUBSTR/CAST en ORDER BY

## Archivos proporcionados

- `schema.sql` — Esquema actual con malas prácticas
- `seed.sql` — Datos de ejemplo
- `slow_queries.sql` — Las 5 queries lentas
- `tests/verify.sql` — Script de verificación

## Archivos que debes crear

### `migrate.sql`
Script con correcciones al esquema:
- CREATE INDEX para índices faltantes
- ALTER TABLE para cambiar tipos VARCHAR→DATE y TEXT→DATE
- ALTER TABLE para agregar FK constraint

### `optimized_queries.sql`
Las 5 queries reescritas usando JOIN, GROUP BY, rangos de fechas, índices

## Restricciones

- Usa SQLite (sintaxis compatible)
- No uses procedimientos almacenados ni funciones específicas de otros motores
- Los scripts deben ejecutarse con `sqlite3 ecommerce.db < script.sql`

## Criterios de evaluación (125 pts)

- Índices agregados correctamente (20 pts)
- Tipos de datos corregidos (10 pts)
- FK constraint agregado (10 pts)
- Cada query optimizada (15 pts c/u, total 75 pts)
- Migración sin errores (10 pts)

## Formato de salida

```sql
-- filepath: migrate.sql
-- ...
```

```sql
-- filepath: optimized_queries.sql
-- ...
```
