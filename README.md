# Benchmark Real de IA ⭐⭐⭐⭐⭐⭐

> Pruebas reales para modelos de IA. Sin benchmarks artificiales, sin preguntas de trivia, sin ejercicios de juguete.

## Motivación

Hoy todos comparan modelos con pruebas artificiales (MMLU, HumanEval, GSM8K...). Pero un desarrollador necesita saber:

- ¿Puede esta IA crear una API completa y funcional?
- ¿Puede corregir un bug real en producción?
- ¿Sabe Docker, Kubernetes, Terraform?
- ¿Entrega código que compile y pase pruebas?

**Benchmark Real de IA** mide lo que realmente importa.

## Retos

| Categoría | Descripción |
|-----------|-------------|
| [API REST](retos/api-rest/) | Crear una API completa con autenticación, DB, tests |
| [Bug Fixing](retos/bug-fixing/) | Corregir bugs reales en código legacy |
| [Docker](retos/docker/) | Dockerizar aplicaciones multi-servicio |
| [Flutter](retos/flutter/) | Programar una app móvil funcional |
| [SQL](retos/sql/) | Optimizar queries lentas y modelar datos |
| [CI/CD](retos/ci-cd/) | Crear pipelines con Jenkins/GitHub Actions |
| [Terraform](retos/terraform/) | Infraestructura como código en AWS/Azure/GCP |
| [Kubernetes](retos/kubernetes/) | Desplegar y gestionar clusters |
| [GoAnywhere](retos/goanywhere/) | Automatización MFT con GoAnywhere |
| [SAP](retos/sap/) | ABAP, RFC, integraciones SAP |
| [AWS](retos/aws/) | Arquitectura serverless, Lambda, Step Functions |

## Métricas

Cada reto se evalúa con:

| Métrica | Descripción |
|---------|-------------|
| ⏱ Tiempo | Tiempo total para completar el reto |
| 💰 Costo | Créditos/tokens consumidos |
| 🏆 Calidad | Evaluación humana del resultado (1-10) |
| ❌ Errores | Número de errores en el código entregado |
| 🌀 Alucinaciones | APIs, librerías o conceptos inventados |
| 📝 Líneas modificadas | Líneas de código añadidas/modificadas |
| ✅ Compilación | ¿El código compila sin errores? |
| 🧪 Pruebas | % de pruebas superadas |

## Estructura del repositorio

```
├── retos/              # Definición de cada reto
│   ├── api-rest/       # Plantilla, descripción, tests
│   ├── bug-fixing/
│   └── ...
├── metricas/           # Sistema de evaluación y plantillas
├── resultados/         # Resultados por modelo
│   ├── gpt-4o/
│   ├── claude-3.5/
│   ├── gemini-2.5/
│   └── ...
└── scripts/            # Scripts de automatización
```

## ¿Cómo contribuir?

1. Añade un nuevo reto en `retos/`
2. Ejecuta un modelo contra los retos existentes
3. Reporta resultados en `resultados/`
4. Mejora el sistema de métricas

## Licencia

MIT
