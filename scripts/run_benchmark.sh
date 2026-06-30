#!/bin/bash
# Script para ejecutar un modelo contra todos los retos
# Uso: ./run_benchmark.sh <modelo> <proveedor>

MODELO=$1
PROVEEDOR=$2
RETOS_DIR="retos"
RESULTADOS_DIR="resultados/${MODELO}"

if [ -z "$MODELO" ] || [ -z "$PROVEEDOR" ]; then
    echo "Uso: $0 <modelo> <proveedor>"
    echo "Ej: $0 gpt-4o openai"
    exit 1
fi

mkdir -p "$RESULTADOS_DIR"

for reto in "$RETOS_DIR"/*/; do
    nombre=$(basename "$reto")
    echo "=== Ejecutando reto: $nombre ==="
    echo "Modelo: $MODELO ($PROVEEDOR)"
    echo "Resultado -> ${RESULTADOS_DIR}/${nombre}.json"
    echo ""
done

echo "Benchmark completado para $MODELO."
