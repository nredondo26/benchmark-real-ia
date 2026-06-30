# Bug Fixing Challenge — Todo List Flask App

Eres un ingeniero de software encargado de corregir una aplicación Flask de lista de tareas.
La aplicación tiene **7 bugs** que deben ser identificados y corregidos. Todos los bugs están en
`buggy_app.py`. No debes modificar los tests ni ningún otro archivo.

## Instalación

```bash
pip install flask pyjwt
```

## Ejecutar tests

```bash
pytest tests/test_app.py -v
```

## Síntomas (lo que el usuario reporta)

1. **Búsqueda rara** — Al buscar tareas, a veces aparecen tareas que no coinciden con la búsqueda.
2. **Actualizaciones que se pierden** — Cuando dos personas actualizan la misma tarea al mismo tiempo,
   a veces un cambio se pierde.
3. **Falta la primera tarea** — En la página 1 del listado nunca aparece la primera tarea.
4. **La app se vuelve lenta** — Después de muchas operaciones, la aplicación consume más y más memoria.
5. **Error de prioridad** — Al filtrar tareas de alta prioridad, la app lanza un error o da resultados
   incorrectos.
6. **Seguridad dudosa** — Cualquiera puede generar un token y acceder a la API.
7. **La app se cuelga** — Si una operación de base de datos falla, la aplicación deja de responder
   indefinidamente.

## Puntuación

- **1 punto por cada bug corregido** (máximo 7 puntos)
- **3 puntos extra** por código limpio (nombres adecuados, sin código muerto, buenas prácticas)
- **Puntuación máxima: 10 puntos**

## Reglas

- Solo modificar `buggy_app.py`
- No modificar los tests ni los archivos de configuración
- Los tests deben pasar en su totalidad
- El código debe ser legible y mantener el estilo existente

## Entrega

Envía únicamente el archivo `buggy_app.py` corregido.
