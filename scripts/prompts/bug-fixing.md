# Reto: Bug Fixing — Todo List Flask App

Eres un ingeniero de software. Se te entrega una aplicación Flask de lista de tareas con **7 bugs**. Debes identificar y corregir todos los bugs. No debes modificar los tests ni ningún otro archivo.

## Bugs reportados por el usuario

1. **Búsqueda rara** — Al buscar tareas, aparecen resultados que no coinciden con la búsqueda.
2. **Actualizaciones que se pierden** — Cuando dos personas actualizan la misma tarea simultáneamente, un cambio se pierde.
3. **Falta la primera tarea** — En la página 1 del listado nunca aparece la primera tarea.
4. **La app se vuelve lenta** — Después de muchas operaciones, la memoria crece sin límite.
5. **Error de prioridad** — Al filtrar por alta prioridad, la app lanza un error o da resultados incorrectos.
6. **Seguridad dudosa** — Cualquiera puede generar un token y acceder a la API.
7. **La app se cuelga** — Si una operación de BD falla, la app deja de responder.

## Archivos

- `buggy_app.py` — Único archivo que puedes modificar
- `tests/test_app.py` — Tests que validan las correcciones (NO MODIFICAR)

## Restricciones

- Solo modifica `buggy_app.py`
- No modifiques los tests (`tests/test_app.py`)
- Los tests deben pasar en su totalidad con `pytest tests/test_app.py -v`
- No añadas nuevas dependencias
- El código debe ser legible y mantener el estilo existente

## Criterios de evaluación

- 7 puntos: 1 punto por cada bug corregido
- 3 puntos extra: código limpio (nombres adecuados, sin código muerto, buenas prácticas)
- Puntuación máxima: 10 puntos

## Formato de salida

```python
# filepath: buggy_app.py
# ... código completo corregido ...
```
