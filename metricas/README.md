# Sistema de Métricas

## Formato de evaluación

Cada reto se evalúa con la siguiente plantilla:

```json
{
  "modelo": "gpt-4o-2024-08-06",
  "reto": "api-rest",
  "fecha": "2024-01-15",
  "metricas": {
    "tiempo_segundos": 2450,
    "costo_usd": 0.85,
    "calidad_1_10": 8,
    "errores": 2,
    "alucinaciones": 1,
    "lineas_modificadas": 340,
    "compila": true,
    "pruebas_superadas_pct": 95.0
  },
  "observaciones": "Buena estructura, pero inventó una librería que no existe.",
  "evaluador": "github-user"
}
```

## Esquema de puntuación

| Métrica | Peso | Notas |
|---------|------|-------|
| Tiempo | 15% | Menos tiempo = mejor puntuación |
| Costo | 10% | Menos costo = mejor puntuación |
| Calidad | 30% | Evaluación humana (1-10) |
| Errores | 15% | Penalización por cada error |
| Alucinaciones | 10% | Penalización por cada alucinación |
| Compilación | 10% | Binario: 0 o 100 |
| Pruebas | 10% | % de pruebas superadas |

## Score total

```
Score = (Tiempo_norm * 0.15) + (Costo_norm * 0.10) + (Calidad/10 * 0.30) + 
        max(0, 1 - Errores*0.03) * 0.15 + max(0, 1 - Alucinaciones*0.05) * 0.10 + 
        Compila * 0.10 + (Pruebas/100) * 0.10
```

Donde `Tiempo_norm` y `Costo_norm` se normalizan contra el mejor resultado registrado.
