# Reto: Pipeline CI/CD

Debes crear pipelines CI/CD completos para una aplicación Node.js/Express usando **Jenkins** y **GitHub Actions**. Los pipelines deben incluir las etapas: lint → test → build → deploy, con despliegue condicional solo en main.

## Estructura del proyecto

```
app/package.json            # Aplicación Node.js/Express
app/src/index.js            # API simple (/, /health, /version)
app/tests/app.test.js       # Tests con Jest + Supertest
template/Jenkinsfile        # Esqueleto de Jenkinsfile
template/.github/workflows/ # Esqueleto de GitHub Actions
tests/validate.sh           # Script de validación
```

## Archivos que debes crear

### `Jenkinsfile`
Pipeline declarativo con stages:
1. Checkout — clonar repositorio
2. Lint — ejecutar ESLint
3. Test — instalar dependencias (con caché), ejecutar `npm test`
4. Build — construir artifact (Docker o npm build)
5. Deploy — solo en rama `main` (directiva `when`)
6. Post — notificaciones en fallo (Slack/email con autor, mensaje, link)

### `.github/workflows/deploy.yml`
Workflow de GitHub Actions con:
1. Disparadores: push en main, PRs (sin deploy en PRs)
2. Jobs: lint, test, build, deploy (condicional)
3. Caché de node_modules con `actions/cache`
4. Secretos con `${{ secrets.SECRET_NAME }}` (nunca hardcodeados)
5. Estrategia de rollback documentada en comentarios

## Requisitos adicionales

- Manejo seguro de secretos (Jenkins: `credentialsId`, GitHub Actions: secrets)
- Caché de dependencias (node_modules)
- Notificaciones en fallo con info del commit
- Estrategia de rollback documentada en comentarios del pipeline

## Restricciones

- No hardcodees tokens, claves SSH, contraseñas ni URLs
- Usa la sintaxis correcta para cada plataforma
- No modifiques los archivos de la aplicación

## Criterios de evaluación (100 pts)

- Pipeline funcional en Jenkins (20 pts)
- Pipeline funcional en GitHub Actions (20 pts)
- Stages bien definidos y en orden correcto (15 pts)
- Deploy condicional solo en main (10 pts)
- Manejo correcto de secretos (10 pts)
- Caché de dependencias (10 pts)
- Notificaciones en fallo (10 pts)
- Estrategia de rollback documentada (5 pts)

## Formato de salida

```groovy
// filepath: Jenkinsfile
// ...
```

```yaml
# filepath: .github/workflows/deploy.yml
# ...
```
