# Reto: API REST — Task Manager

Eres un desarrollador backend. Debes implementar una API REST funcional para un sistema de gestión de tareas con autenticación JWT, CRUD completo, paginación, filtros y pruebas de integración.

## Especificación técnica

- **Framework:** FastAPI (Python 3.12)
- **Base de datos:** SQLite con SQLAlchemy
- **Autenticación:** JWT con pyjwt, contraseñas hasheadas con bcrypt
- **Documentación:** La especificación OpenAPI 3.0 está en `spec.yaml`

## Endpoints requeridos

| Método | Ruta | Descripción |
|--------|------|-------------|
| POST | /auth/login | Iniciar sesión, devuelve JWT |
| GET | /users/me | Obtener usuario autenticado |
| POST | /tasks | Crear tarea (201) |
| GET | /tasks | Listar tareas (paginado + filtro por status) |
| GET | /tasks/{id} | Obtener tarea por ID |
| PUT | /tasks/{id} | Actualizar tarea |
| DELETE | /tasks/{id} | Eliminar tarea (204) |

## Archivos que debes crear

Crea los siguientes archivos con el código completo:

### `main.py`
Implementación completa de la API con:
- Modelos SQLAlchemy para User y Task
- Esquemas Pydantic para validación (LoginRequest, LoginResponse, TaskIn, TaskOut, TaskUpdate, TaskListResponse, UserOut, ErrorResponse)
- Endpoints de autenticación JWT
- CRUD de tareas con paginación (page, size) y filtro por status
- Aislamiento: cada usuario solo ve/modifica sus propias tareas
- La base de datos se crea automáticamente al iniciar
- Seed de un usuario de prueba al iniciar

### `requirements.txt`
Dependencias: fastapi, uvicorn, sqlalchemy, pyjwt, bcrypt, python-multipart

## Restricciones

- No uses servicios externos, APIs de terceros ni bases de datos en la nube
- Todo debe ser autocontenido y ejecutable con `pip install -r requirements.txt`
- No modifiques los tests existentes
- El código debe escribirse en inglés (variables, funciones, comentarios)

## Criterios de evaluación

- Autenticación JWT funcional (login, validación, expiración, hasheo de contraseñas)
- CRUD completo de tareas con códigos HTTP correctos (201, 204, 404, 401, 422)
- Paginación con parámetros page/size y filtro por status
- Aislamiento de datos por usuario
- Pruebas de integración existentes pasan correctamente

## Formato de salida

Usa bloques de código con el lenguaje y la ruta del archivo como comentario en la primera línea.

```python
# filepath: main.py
# ... código completo ...
```

```text
# filepath: requirements.txt
# ... dependencias ...
```
