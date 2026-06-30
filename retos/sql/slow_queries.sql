-- ============================================================
-- 5 QUERIES LENTAS PARA OPTIMIZAR
-- ============================================================
-- Cada query incluye: número, problema, query original y espacio
-- para la solución.
-- ============================================================

-- ============================================================
-- QUERY 1: Full table scan en products por función en WHERE
-- ============================================================
-- Problema: Usa YEAR() sobre la columna created_at, lo que
-- impide usar cualquier índice. Hace un scan completo.
--
-- Objetivo: Reescribir para que use búsqueda por rango de
-- fechas y pueda aprovechar un índice en created_at.

-- LENTA:
SELECT p.id, p.name, p.price, p.stock
FROM products p
WHERE CAST(strftime('%Y', p.created_at) AS INTEGER) = 2024
ORDER BY p.price DESC;

-- SOLUCIÓN (escribe aquí):



-- ============================================================
-- QUERY 2: N+1 disfrazado de JOIN
-- ============================================================
-- Problema: Para cada orden, obtiene el nombre del cliente
-- mediante una subconsulta correlacionada. Si hay 200 órdenes,
-- ejecuta 200 subconsultas.
--
-- Objetivo: Reemplazar con un JOIN simple.

-- LENTA:
SELECT
    o.id AS order_id,
    o.order_date,
    o.total,
    (SELECT c.name FROM customers c WHERE c.id = o.customer_id) AS customer_name,
    (SELECT c.email FROM customers c WHERE c.id = o.customer_id) AS customer_email
FROM orders o
WHERE o.status = 'entregado';

-- SOLUCIÓN (escribe aquí):



-- ============================================================
-- QUERY 3: LIKE con comodín al inicio en columna no indexada
-- ============================================================
-- Problema: Busca productos por palabra clave en la descripción
-- usando LIKE '%term%'. Esto impide usar índices incluso si
-- existiera uno, y description no tiene índice.
--
-- Objetivo: Agregar un índice FULLTEXT y usar MATCH...AGAINST,
-- o al menos usar un índice y LIKE sin comodín izquierdo.

-- LENTA:
SELECT p.id, p.name, p.price, p.stock
FROM products p
WHERE p.description LIKE '%inalámbrico%'
   OR p.description LIKE '%bluetooth%'
   OR p.description LIKE '%smart%'
ORDER BY p.price;

-- SOLUCIÓN (escribe aquí):



-- ============================================================
-- QUERY 4: Correlated subquery para total por cliente
-- ============================================================
-- Problema: Para cada cliente, calcula el total gastado y el
-- número de órdenes mediante subconsultas que se ejecutan una
-- vez por fila. Además convierte order_date con substr().
--
-- Objetivo: Usar GROUP BY con funciones de ventana o agregación.

-- LENTA:
SELECT
    c.id,
    c.name,
    c.email,
    (SELECT COUNT(*) FROM orders o WHERE o.customer_id = c.id) AS total_orders,
    (SELECT SUM(o.total) FROM orders o WHERE o.customer_id = c.id) AS total_spent,
    (SELECT MAX(o.total) FROM orders o WHERE o.customer_id = c.id) AS max_order,
    (SELECT SUBSTR(o.order_date, 1, 7) FROM orders o WHERE o.customer_id = c.id ORDER BY o.id DESC LIMIT 1) AS last_order_month
FROM customers c
WHERE c.id IN (SELECT DISTINCT customer_id FROM orders)
ORDER BY total_spent DESC;

-- SOLUCIÓN (escribe aquí):



-- ============================================================
-- QUERY 5: Ordenamiento sin índice + funciones en ORDER BY
-- ============================================================
-- Problema: Ordena órdenes por total en ORDER BY, pero total
-- no tiene índice. Además usa SUBSTR y CAST en ORDER BY y
-- filtra por status sin índice. El ORDER BY sobre una
-- expresión hace que el sort sea en disco.
--
-- Objetivo: Agregar índices compuestos y evitar funciones
-- en ORDER BY.

-- LENTA:
SELECT
    o.id,
    c.name AS cliente,
    o.total,
    o.status,
    SUBSTR(o.order_date, 1, 10) AS fecha_orden
FROM orders o
JOIN customers c ON c.id = o.customer_id
WHERE o.status IN ('pendiente', 'enviado')
ORDER BY o.total DESC, CAST(SUBSTR(o.order_date, 1, 4) AS INTEGER) DESC;

-- SOLUCIÓN (escribe aquí):
