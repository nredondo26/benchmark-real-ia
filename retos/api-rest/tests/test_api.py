"""
Tests de integración para la Task Manager API.
Ejecutar con: pytest tests/test_api.py -v
"""

import pytest
from httpx import AsyncClient, ASGITransport
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from sqlalchemy.pool import StaticPool

# Se asume que la implementación está en template/main.py
import sys
sys.path.insert(0, "template")

from main import (
    app,
    Base,
    get_db,
    UserModel,
    hash_password,
    create_access_token,
)

# ---------------------------------------------------------------------------
# Base de datos en memoria para tests
# ---------------------------------------------------------------------------
TEST_DATABASE_URL = "sqlite:///:memory:"

engine_test = create_engine(
    TEST_DATABASE_URL,
    connect_args={"check_same_thread": False},
    poolclass=StaticPool,
)
TestingSessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine_test)


def override_get_db():
    db = TestingSessionLocal()
    try:
        yield db
    finally:
        db.close()


app.dependency_overrides[get_db] = override_get_db


# ---------------------------------------------------------------------------
# Fixtures
# ---------------------------------------------------------------------------
@pytest.fixture(autouse=True)
def setup_db():
    """Crea las tablas antes de cada test y las limpia al terminar."""
    Base.metadata.create_all(bind=engine_test)
    yield
    Base.metadata.drop_all(bind=engine_test)


@pytest.fixture
def test_user(db_session: TestingSessionLocal):
    """Crea un usuario de prueba y devuelve sus datos."""
    user = UserModel(
        username="testuser",
        email="test@example.com",
        hashed_password=hash_password("secret123"),
    )
    db_session.add(user)
    db_session.commit()
    db_session.refresh(user)
    return user


@pytest.fixture
def token(test_user) -> str:
    """Genera un token JWT para el usuario de prueba."""
    return create_access_token(data={"sub": test_user.id})


@pytest.fixture
def auth_headers(token: str) -> dict:
    """Headers de autorización con el token JWT."""
    return {"Authorization": f"Bearer {token}"}


@pytest.fixture
def db_session():
    """Proporciona una sesión de base de datos para los fixtures."""
    db = TestingSessionLocal()
    try:
        yield db
    finally:
        db.close()


# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------
@pytest.fixture
def client():
    """Cliente HTTP asíncrono conectado a la aplicación."""
    transport = ASGITransport(app=app)
    return AsyncClient(transport=transport, base_url="http://test")


# ===================================================================
# Tests
# ===================================================================


class TestAuth:
    """Pruebas del flujo de autenticación."""

    @pytest.mark.asyncio
    async def test_login_success(self, client, test_user):
        """Debe retornar un token JWT con credenciales válidas."""
        response = await client.post(
            "/auth/login",
            json={"username": "testuser", "password": "secret123"},
        )
        assert response.status_code == 200
        data = response.json()
        assert "access_token" in data
        assert data["token_type"] == "bearer"

    @pytest.mark.asyncio
    async def test_login_invalid_credentials(self, client):
        """Debe retornar 401 con credenciales inválidas."""
        response = await client.post(
            "/auth/login",
            json={"username": "wrong", "password": "wrong"},
        )
        assert response.status_code == 401

    @pytest.mark.asyncio
    async def test_login_wrong_password(self, client, test_user):
        """Debe retornar 401 con contraseña incorrecta."""
        response = await client.post(
            "/auth/login",
            json={"username": "testuser", "password": "wrongpass"},
        )
        assert response.status_code == 401

    @pytest.mark.asyncio
    async def test_login_missing_fields(self, client):
        """Debe retornar 422 si faltan campos requeridos."""
        response = await client.post("/auth/login", json={})
        assert response.status_code == 422


class TestUsersMe:
    """Pruebas del endpoint /users/me."""

    @pytest.mark.asyncio
    async def test_get_current_user(self, client, auth_headers, test_user):
        """Debe retornar los datos del usuario autenticado."""
        response = await client.get("/users/me", headers=auth_headers)
        assert response.status_code == 200
        data = response.json()
        assert data["username"] == test_user.username
        assert data["email"] == test_user.email
        assert data["id"] == test_user.id

    @pytest.mark.asyncio
    async def test_get_current_user_no_token(self, client):
        """Debe retornar 401 si no se envía token."""
        response = await client.get("/users/me")
        assert response.status_code == 401

    @pytest.mark.asyncio
    async def test_get_current_user_invalid_token(self, client):
        """Debe retornar 401 con token inválido."""
        headers = {"Authorization": "Bearer token-invalido"}
        response = await client.get("/users/me", headers=headers)
        assert response.status_code == 401


class TestTasksCRUD:
    """Pruebas completas de CRUD de tareas."""

    @pytest.mark.asyncio
    async def test_create_task(self, client, auth_headers):
        """Debe crear una tarea y retornar sus datos."""
        response = await client.post(
            "/tasks",
            headers=auth_headers,
            json={"title": "Mi primera tarea", "priority": 5},
        )
        assert response.status_code == 201
        data = response.json()
        assert data["title"] == "Mi primera tarea"
        assert data["priority"] == 5
        assert data["status"] == "pending"
        assert "id" in data
        assert "created_at" in data

    @pytest.mark.asyncio
    async def test_create_task_with_all_fields(self, client, auth_headers):
        """Debe crear una tarea con todos los campos opcionales."""
        response = await client.post(
            "/tasks",
            headers=auth_headers,
            json={
                "title": "Tarea completa",
                "description": "Descripción detallada",
                "status": "in_progress",
                "priority": 4,
            },
        )
        assert response.status_code == 201
        data = response.json()
        assert data["title"] == "Tarea completa"
        assert data["description"] == "Descripción detallada"
        assert data["status"] == "in_progress"
        assert data["priority"] == 4

    @pytest.mark.asyncio
    async def test_create_task_no_title(self, client, auth_headers):
        """Debe retornar 422 si falta el título."""
        response = await client.post(
            "/tasks",
            headers=auth_headers,
            json={},
        )
        assert response.status_code == 422

    @pytest.mark.asyncio
    async def test_create_task_unauthorized(self, client):
        """Debe retornar 401 sin autenticación."""
        response = await client.post(
            "/tasks",
            json={"title": "Tarea sin auth"},
        )
        assert response.status_code == 401

    @pytest.mark.asyncio
    async def test_list_tasks(self, client, auth_headers):
        """Debe listar las tareas del usuario."""
        # Crear varias tareas
        for i in range(5):
            await client.post(
                "/tasks",
                headers=auth_headers,
                json={"title": f"Tarea {i}"},
            )

        response = await client.get("/tasks", headers=auth_headers)
        assert response.status_code == 200
        data = response.json()
        assert data["total"] == 5
        assert len(data["items"]) == 5
        assert data["page"] == 1
        assert data["size"] == 10

    @pytest.mark.asyncio
    async def test_list_tasks_pagination(self, client, auth_headers):
        """Debe paginar correctamente los resultados."""
        for i in range(15):
            await client.post(
                "/tasks",
                headers=auth_headers,
                json={"title": f"Tarea {i}"},
            )

        response = await client.get(
            "/tasks",
            headers=auth_headers,
            params={"page": 2, "size": 5},
        )
        assert response.status_code == 200
        data = response.json()
        assert data["total"] == 15
        assert len(data["items"]) == 5
        assert data["page"] == 2
        assert data["size"] == 5

    @pytest.mark.asyncio
    async def test_list_tasks_filter_by_status(self, client, auth_headers):
        """Debe filtrar tareas por estado."""
        await client.post(
            "/tasks",
            headers=auth_headers,
            json={"title": "Pending", "status": "pending"},
        )
        await client.post(
            "/tasks",
            headers=auth_headers,
            json={"title": "In Progress", "status": "in_progress"},
        )
        await client.post(
            "/tasks",
            headers=auth_headers,
            json={"title": "Completed", "status": "completed"},
        )

        response = await client.get(
            "/tasks",
            headers=auth_headers,
            params={"status": "completed"},
        )
        assert response.status_code == 200
        data = response.json()
        assert data["total"] == 1
        assert data["items"][0]["title"] == "Completed"

    @pytest.mark.asyncio
    async def test_list_tasks_empty(self, client, auth_headers):
        """Debe retornar lista vacía si no hay tareas."""
        response = await client.get("/tasks", headers=auth_headers)
        assert response.status_code == 200
        data = response.json()
        assert data["total"] == 0
        assert data["items"] == []

    @pytest.mark.asyncio
    async def test_get_task(self, client, auth_headers):
        """Debe obtener una tarea por ID."""
        created = await client.post(
            "/tasks",
            headers=auth_headers,
            json={"title": "Tarea a buscar"},
        )
        task_id = created.json()["id"]

        response = await client.get(f"/tasks/{task_id}", headers=auth_headers)
        assert response.status_code == 200
        assert response.json()["title"] == "Tarea a buscar"

    @pytest.mark.asyncio
    async def test_get_task_not_found(self, client, auth_headers):
        """Debe retornar 404 si la tarea no existe."""
        response = await client.get("/tasks/99999", headers=auth_headers)
        assert response.status_code == 404

    @pytest.mark.asyncio
    async def test_get_task_unauthorized(self, client, test_user):
        """Debe retornar 401 si no hay token."""
        response = await client.get("/tasks/1")
        assert response.status_code == 401

    @pytest.mark.asyncio
    async def test_update_task(self, client, auth_headers):
        """Debe actualizar una tarea existente."""
        created = await client.post(
            "/tasks",
            headers=auth_headers,
            json={"title": "Original"},
        )
        task_id = created.json()["id"]

        response = await client.put(
            f"/tasks/{task_id}",
            headers=auth_headers,
            json={"title": "Actualizado", "status": "completed"},
        )
        assert response.status_code == 200
        data = response.json()
        assert data["title"] == "Actualizado"
        assert data["status"] == "completed"

    @pytest.mark.asyncio
    async def test_update_task_partial(self, client, auth_headers):
        """Debe permitir actualización parcial (solo priority)."""
        created = await client.post(
            "/tasks",
            headers=auth_headers,
            json={"title": "Original", "priority": 1},
        )
        task_id = created.json()["id"]

        response = await client.put(
            f"/tasks/{task_id}",
            headers=auth_headers,
            json={"priority": 5},
        )
        assert response.status_code == 200
        data = response.json()
        assert data["title"] == "Original"
        assert data["priority"] == 5

    @pytest.mark.asyncio
    async def test_update_task_not_found(self, client, auth_headers):
        """Debe retornar 404 al actualizar una tarea inexistente."""
        response = await client.put(
            "/tasks/99999",
            headers=auth_headers,
            json={"title": "No existe"},
        )
        assert response.status_code == 404

    @pytest.mark.asyncio
    async def test_delete_task(self, client, auth_headers):
        """Debe eliminar una tarea existente."""
        created = await client.post(
            "/tasks",
            headers=auth_headers,
            json={"title": "A eliminar"},
        )
        task_id = created.json()["id"]

        response = await client.delete(f"/tasks/{task_id}", headers=auth_headers)
        assert response.status_code == 204

        # Verificar que ya no existe
        response = await client.get(f"/tasks/{task_id}", headers=auth_headers)
        assert response.status_code == 404

    @pytest.mark.asyncio
    async def test_delete_task_not_found(self, client, auth_headers):
        """Debe retornar 404 al eliminar una tarea inexistente."""
        response = await client.delete("/tasks/99999", headers=auth_headers)
        assert response.status_code == 404

    @pytest.mark.asyncio
    async def test_cannot_access_other_user_task(self, client, test_user, auth_headers, db_session):
        """Un usuario no debe poder ver tareas de otro usuario."""
        # Crear tarea como test_user
        created = await client.post(
            "/tasks",
            headers=auth_headers,
            json={"title": "Tarea privada"},
        )
        task_id = created.json()["id"]

        # Crear otro usuario
        other_user = UserModel(
            username="other",
            email="other@example.com",
            hashed_password=hash_password("pass"),
        )
        db_session.add(other_user)
        db_session.commit()

        other_token = create_access_token(data={"sub": other_user.id})
        other_headers = {"Authorization": f"Bearer {other_token}"}

        # Intentar acceder a la tarea del primer usuario
        response = await client.get(f"/tasks/{task_id}", headers=other_headers)
        assert response.status_code == 404
