-- ============================================================
-- VERIFICACIÓN DE OPTIMIZACIONES
-- ============================================================
-- Estas queries evalúan si se aplicaron las correcciones.
-- Ejecutar con: sqlite3 ecommerce.db < tests/verify.sql
-- ============================================================

.print ''
.print '============================================'
.print ' VERIFICACIÓN DE OPTIMIZACIONES'
.print '============================================'

.print ''
.print '--- 1. ÍNDICES AGREGADOS ---'

-- Verificar índices en tablas
SELECT 'INDICE_EN_CATEGORY_ID' AS test,
       CASE WHEN EXISTS (
           SELECT 1 FROM sqlite_master
           WHERE type = 'index'
             AND sql LIKE '%category_id%'
             AND tbl_name = 'products'
       ) THEN 'PASS' ELSE 'FAIL (falta índice en products.category_id)' END AS result;

SELECT 'INDICE_EN_CUSTOMER_ID' AS test,
       CASE WHEN EXISTS (
           SELECT 1 FROM sqlite_master
           WHERE type = 'index'
             AND sql LIKE '%customer_id%'
             AND tbl_name = 'orders'
       ) THEN 'PASS' ELSE 'FAIL (falta índice en orders.customer_id)' END AS result;

SELECT 'FK_ORDER_ITEMS' AS test,
       CASE WHEN EXISTS (
           SELECT 1 FROM sqlite_master
           WHERE type = 'table'
             AND name = 'order_items'
             AND sql LIKE '%REFERENCES orders%'
       ) THEN 'PASS' ELSE 'FAIL (falta FK constraint en order_items → orders)' END AS result;

.print ''
.print '--- 2. TIPOS DE DATOS CORREGIDOS ---'

SELECT 'ORDER_DATE_TYPE' AS test,
       CASE WHEN EXISTS (
           SELECT 1 FROM pragma_table_info('orders')
           WHERE name = 'order_date' AND type = 'DATE'
       ) THEN 'PASS' ELSE 'FAIL (order_date debería ser DATE en vez de VARCHAR)' END AS result;

SELECT 'REVIEW_DATE_TYPE' AS test,
       CASE WHEN EXISTS (
           SELECT 1 FROM pragma_table_info('reviews')
           WHERE name = 'review_date' AND type = 'DATE'
       ) THEN 'PASS' ELSE 'FAIL (review_date debería ser DATE en vez de TEXT)' END AS result;

.print ''
.print '--- 3. PLAN DE EJECUCIÓN - QUERY 1 ---'
-- Debe mostrar SCAN en lugar de SEARCH si no tiene índice en created_at
EXPLAIN QUERY PLAN
SELECT p.id, p.name, p.price
FROM products p
WHERE p.created_at >= '2024-01-01' AND p.created_at < '2025-01-01'
ORDER BY p.price DESC;

.print ''
.print '--- 4. PLAN DE EJECUCIÓN - QUERY 2 ---'
-- Debe mostrar un JOIN en lugar de subconsultas correlacionadas
EXPLAIN QUERY PLAN
SELECT o.id, o.order_date, o.total, c.name, c.email
FROM orders o
JOIN customers c ON c.id = o.customer_id
WHERE o.status = 'entregado';

.print ''
.print '--- 5. PLAN DE EJECUCIÓN - QUERY 3 ---'
-- Debe usar un índice (SEARCH con índice) o búsqueda FULLTEXT
EXPLAIN QUERY PLAN
SELECT p.id, p.name, p.price
FROM products p
WHERE p.description LIKE 'inalámbrico%'
   OR p.description LIKE 'bluetooth%'
   OR p.description LIKE 'smart%'
ORDER BY p.price;

.print ''
.print '--- 6. PLAN DE EJECUCIÓN - QUERY 4 ---'
-- Debe usar GROUP BY en lugar de subconsultas correlacionadas
EXPLAIN QUERY PLAN
SELECT c.id, c.name,
       COUNT(o.id) AS total_orders,
       SUM(o.total) AS total_spent,
       MAX(o.total) AS max_order
FROM customers c
JOIN orders o ON o.customer_id = c.id
GROUP BY c.id
ORDER BY total_spent DESC;

.print ''
.print '--- 7. PLAN DE EJECUCIÓN - QUERY 5 ---'
-- Debe usar índices para ORDER BY (total, order_date)
EXPLAIN QUERY PLAN
SELECT o.id, c.name, o.total, o.status, o.order_date
FROM orders o
JOIN customers c ON c.id = o.customer_id
WHERE o.status IN ('pendiente', 'enviado')
ORDER BY o.total DESC, o.order_date DESC;

.print ''
.print '============================================'
.print ' VERIFICACIÓN COMPLETADA'
.print '============================================'
