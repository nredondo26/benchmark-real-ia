# 🚀 Reto: Pipeline CI/CD

## Objetivo

Crear pipelines CI/CD completos para una aplicación Node.js/Express usando **Jenkins** (Jenkinsfile) y **GitHub Actions** (`.github/workflows/deploy.yml`).

Los pipelines deben pasar por las etapas: **lint → test → build → deploy**, con despliegue condicional solo en la rama `main`, manejo seguro de secretos, caché de dependencias, notificaciones en fallo y estrategia de rollback.

---

## 📁 Estructura del proyecto

```
ci-cd/
├── app/                        # Aplicación Node.js/Express
│   ├── package.json
│   ├── src/
│   │   └── index.js            # API simple (endpoints: /, /health, /version)
│   └── tests/
│       └── app.test.js         # 2 tests con Jest + Supertest
├── template/                   # Esqueletos de pipelines para completar
│   ├── Jenkinsfile
│   └── .github/workflows/
│       └── deploy.yml
├── tests/
│   └── validate.sh             # Script de validación de los pipelines
└── README.md                   # Este archivo
```

---

## 📋 Requisitos del pipeline

### 1. Stages obligatorios

| Stage       | Descripción                                                     |
|-------------|-----------------------------------------------------------------|
| `Checkout`  | Clonar el repositorio                                           |
| `Lint`      | Ejecutar ESLint                                                 |
| `Test`      | Instalar dependencias (con caché) y ejecutar `npm test`          |
| `Build`     | Construir imagen Docker o artifact de build                      |
| `Deploy`    | Desplegar solo en la rama `main`                                 |

### 2. Despliegue condicional

- El stage `Deploy` debe ejecutarse **solo cuando el push sea a la rama `main`**.
- En GitHub Actions, los PRs no deben disparar el deploy.
- En Jenkins, usar la directiva `when`.

### 3. Manejo de secretos ❌🚫

- **NUNCA hardcodear** tokens, claves SSH, contraseñas o URLs de registro.
- Jenkins: usar el plugin **Credentials** con `credentialsId` y `credentials()`.
- GitHub Actions: usar **GitHub Secrets** con `${{ secrets.SECRET_NAME }}`.

### 4. Caché de dependencias ⚡

- Cachear `node_modules` para evitar descargas completas en cada ejecución.
- En GitHub Actions: usar `actions/cache` apuntando a `node_modules`.
- En Jenkins: usar la opción `cache` del pipeline o herramienta externa.

### 5. Notificaciones 🔔

- Enviar notificación **Slack** o **email** cuando el pipeline falle.
- Incluir información del commit (autor, mensaje, link al build).

### 6. Estrategia de rollback ↩️

- Documentar e implementar una estrategia de rollback en caso de fallo del deploy.
- Ejemplos:
  - Re-desplegar la imagen Docker anterior (tag `previous` o SHA conocido).
  - Usar blue/green deployment y revertir el tráfico.
  - Restaurar un backup del artefacto anterior.

---

## 🏆 Criterios de evaluación (puntuación)

| Criterio                                    | Puntos |
|---------------------------------------------|--------|
| Pipeline funcional en Jenkins               | 20     |
| Pipeline funcional en GitHub Actions        | 20     |
| Stages bien definidos y en orden correcto   | 15     |
| Deploy condicional (solo main)              | 10     |
| Manejo correcto de secretos                 | 10     |
| Caché de dependencias implementado          | 10     |
| Notificaciones en fallo                     | 10     |
| Estrategia de rollback documentada          | 5      |
| **Total**                                   | **100**|

---

## ▶️ Cómo ejecutar la validación

```bash
# Dar permisos y ejecutar el validador
chmod +x tests/validate.sh
./tests/validate.sh
```

El script verifica que los archivos de pipeline existan y contengan las secciones obligatorias.

---

## 🧪 Cómo probar la app localmente

```bash
cd app
npm install
npm test          # Ejecuta los tests
npm start         # Inicia el servidor en puerto 3000
```
