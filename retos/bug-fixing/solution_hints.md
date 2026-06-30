# Solution Hints (for evaluators)

## Bug 1 — SQL Injection
**Archivo:** `buggy_app.py`
**Ruta:** `/api/tasks/search` — línea de la query SQL
**Problema:** El parámetro `q` se interpola directamente en la SQL con f-string:
```python
sql = f"SELECT * FROM tasks WHERE title LIKE '%{query}%'"
```
**Fix:** Usar consultas parametrizadas con `?`:
```python
sql = "SELECT * FROM tasks WHERE title LIKE ?"
cursor = get_db().execute(sql, (f'%{query}%',))
```

---

## Bug 2 — Race Condition
**Archivo:** `buggy_app.py`
**Ruta:** `/api/tasks/<int:task_id>` (PUT) — función `update_task`
**Problema:** Se lee la tarea, se calcula `new_version`, se hace `time.sleep(0.05)`, y luego se escribe. Sin un lock, dos requests concurrentes leen la misma versión y una sobrescribe a la otra.
**Fix:** Agregar un `threading.Lock` que proteja la sección crítica (lectura → modificación → escritura):
```python
update_lock = threading.Lock()

@app.route('/api/tasks/<int:task_id>', methods=['PUT'])
@token_required
def update_task(task_id):
    with update_lock:
        task = get_db().execute(...).fetchone()
        new_version = task['version'] + 1
        time.sleep(0.05)
        get_db().execute(...)
        get_db().commit()
    ...
```

---

## Bug 3 — Off-by-One en Paginación
**Archivo:** `buggy_app.py`
**Ruta:** `/api/tasks` (GET) — función `get_tasks`
**Problema:** El offset se calcula con `+ 1` extra:
```python
offset = (page - 1) * per_page + 1
```
Esto salta el primer elemento (id=1 nunca aparece en la página 1).
**Fix:** Eliminar el `+ 1`:
```python
offset = (page - 1) * per_page
```

---

## Bug 4 — Memory Leak
**Archivo:** `buggy_app.py`
**Variable global:** `request_log`
**Problema:** Cada request PUT agrega una entrada a `request_log` sin límite. Con el tiempo crece sin control.
**Fix:** Usar `collections.deque(maxlen=100)` en lugar de `[]`, o limitar el tamaño manualmente:
```python
from collections import deque
request_log = deque(maxlen=100)
```
Si se mantiene como lista, verificar `len(request_log)` y hacer `pop(0)` cuando exceda el límite.

---

## Bug 5 — Type Error (String vs Int)
**Archivo:** `buggy_app.py`
**Ruta:** `/api/tasks/high-priority` (GET) — función `high_priority_tasks`
**Problema:** La columna `priority` es TEXT en SQLite, pero se compara con un entero:
```python
if t['priority'] > 5:
```
En Python 3, comparar un string con un int lanza `TypeError` (o en SQLite puede dar resultados incorrectos).
**Fix:** Convertir a `int` antes de comparar:
```python
if int(t['priority']) > 5:
```

---

## Bug 6 — Broken Authentication (JWT Secret débil y hardcodeado)
**Archivo:** `buggy_app.py`
**Variable global:** `SECRET_KEY`
**Problema:** La clave JWT está hardcodeada como `"secret"`, que es débil y además es la misma en todos los entornos.
**Fix:** Leer la clave desde una variable de entorno con un fallback seguro:
```python
SECRET_KEY = os.environ.get('JWT_SECRET', 'change-me-in-production')
```
Asegurarse de que en producción se configure `JWT_SECRET` con un valor seguro.

---

## Bug 7 — Infinite Loop en Retry Logic
**Archivo:** `buggy_app.py`
**Función:** `retry_on_failure`
**Problema:** El bucle `while True` no tiene condición de salida. Si la operación siempre falla, el programa se cuelga para siempre.
**Fix:** Agregar un contador de reintentos y un límite máximo:
```python
def retry_on_failure(operation, max_retries=3):
    for attempt in range(max_retries):
        try:
            return operation()
        except Exception:
            if attempt == max_retries - 1:
                raise
            time.sleep(0.1)
```
