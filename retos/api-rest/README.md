# Reto: API REST — Task Manager

## Objetivo

Crear una API REST funcional para un sistema de gestión de tareas (Task Manager)
implementando **autenticación JWT**, **CRUD completo**, **paginación**, **filtros**
y **pruebas de integración**.

El código debe escribirse en **inglés** (variables, comentarios, nombres de
funciones). Las instrucciones de este README están en español.

## Especificación técnica

- **Framework:** FastAPI (Python)
- **Base de datos:** SQLite con SQLAlchemy
- **Autenticación:** JWT (pyjwt)
- **Documentación:** OpenAPI 3.0 (spec.yaml)

## Endpoints requeridos

| Método | Ruta            | Descripción                       |
|--------|-----------------|-----------------------------------|
| POST   | /auth/login     | Iniciar sesión, devuelve JWT      |
| GET    | /users/me       | Obtener usuario autenticado       |
| POST   | /tasks          | Crear tarea                       |
| GET    | /tasks          | Listar tareas (paginado + filtro) |
| GET    | /tasks/{id}     | Obtener tarea por ID              |
| PUT    | /tasks/{id}     | Actualizar tarea                  |
| DELETE | /tasks/{id}     | Eliminar tarea                    |

## Archivos

| Archivo               | Propósito                                              |
|-----------------------|--------------------------------------------------------|
| `spec.yaml`           | Especificación OpenAPI 3.0 completa                    |
| `template/main.py`    | Plantilla con imports, modelos y estructura vacía      |
| `tests/test_api.py`   | Suite de tests con pytest + httpx                      |
| `requirements.txt`    | Dependencias del proyecto                              |
| `README.md`           | Este archivo                                           |

## Cómo empezar

```bash
# 1. Instalar dependencias
pip install -r requirements.txt

# 2. Implementar la lógica en template/main.py
#    (reemplazar los pass con implementaciones reales)

# 3. Ejecutar la API
cd template && python main.py

# 4. Ejecutar los tests
pytest tests/test_api.py -v
```

## Criterios de evaluación (20 puntos)

### 1. Autenticación JWT — 4 puntos
- [ ] 1 pt — POST /auth/login valida credenciales y retorna token
- [ ] 1 pt — Contraseñas hasheadas (bcrypt)
- [ ] 1 pt — Token expira y se valida correctamente
- [ ] 1 pt — GET /users/me retorna el usuario del token

### 2. CRUD de tareas — 6 puntos
- [ ] 1 pt — POST /tasks crea tarea y retorna 201
- [ ] 1 pt — GET /tasks lista tareas del usuario autenticado
- [ ] 1 pt — GET /tasks/{id} retorna tarea específica
- [ ] 1 pt — PUT /tasks/{id} actualiza tarea
- [ ] 1 pt — DELETE /tasks/{id} elimina tarea y retorna 204
- [ ] 1 pt — Los usuarios solo ven/modifican sus propias tareas

### 3. Paginación y filtros — 3 puntos
- [ ] 1 pt — Parámetros `page` y `size` funcionan correctamente
- [ ] 1 pt — Filtro por `status` (pending, in_progress, completed)
- [ ] 1 pt — Respuesta incluye `total`, `items`, `page`, `size`

### 4. Validación y errores — 3 puntos
- [ ] 1 pt — 422 en datos inválidos (título vacío, prioridad fuera de rango)
- [ ] 1 pt — 404 cuando un recurso no existe
- [ ] 1 pt — 401 cuando no hay token o es inválido

### 5. Tests — 4 puntos
- [ ] 1 pt — Tests de autenticación (login exitoso, credenciales inválidas)
- [ ] 1 pt — Tests de CRUD (crear, listar, obtener, actualizar, eliminar)
- [ ] 1 pt — Tests de casos error (404, 401, 422)
- [ ] 1 pt — Tests de paginación y filtros

### Total: 20 puntos

## Notas

- La base de datos debe crearse automáticamente al iniciar la app
- El seed de un usuario de prueba puede hacerse manual o mediante un endpoint
- Los tests usan una base de datos en memoria (`:memory:`)
- No se requiere Docker, pero la solución debe ser reproducible con `pip install`
