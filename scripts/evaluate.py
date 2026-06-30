#!/usr/bin/env python3
"""Script para calcular score normalizado de un resultado."""

import json
import sys
from pathlib import Path


def normalize(value, best, worst):
    if worst == best:
        return 1.0
    return 1 - (value - best) / (worst - best)


def calculate_score(result, best_times, best_costs):
    m = result["metricas"]

    tiempo_norm = normalize(m["tiempo_segundos"], best_times.get(result["reto"], 0), m["tiempo_segundos"] * 2)
    costo_norm = normalize(m["costo_usd"], best_costs.get(result["reto"], 0), m["costo_usd"] * 2)
    calidad = m["calidad_1_10"] / 10
    errores_penalty = max(0, 1 - m["errores"] * 0.03)
    alucinaciones_penalty = max(0, 1 - m["alucinaciones"] * 0.05)
    compila = 1 if m["compila"] else 0
    pruebas = m["pruebas_superadas_pct"] / 100

    score = (
        tiempo_norm * 0.15
        + costo_norm * 0.10
        + calidad * 0.30
        + errores_penalty * 0.15
        + alucinaciones_penalty * 0.10
        + compila * 0.10
        + pruebas * 0.10
    )
    return round(score * 100, 2)


def main():
    if len(sys.argv) < 2:
        print("Uso: evaluate.py <resultado.json>")
        sys.exit(1)

    path = Path(sys.argv[1])
    result = json.loads(path.read_text())

    score = calculate_score(result)
    print(f"Score: {score}/100")
    return score


if __name__ == "__main__":
    main()
