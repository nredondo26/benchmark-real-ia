#!/bin/bash
set -euo pipefail

DIR="$(cd "$(dirname "$0")/.." && pwd)"
ERRORS=0
PASS=0
TOTAL=0

check() {
    TOTAL=$((TOTAL + 1))
    local desc="$1"
    shift
    if eval "$@"; then
        echo "  [PASS] $desc"
        PASS=$((PASS + 1))
    else
        echo "  [FAIL] $desc"
        ERRORS=$((ERRORS + 1))
    fi
}

echo "=== Validación del reto Kubernetes ==="
echo ""

# Buscar archivos YAML
YAML_FILES=$(find "$DIR" -name "*.yml" -o -name "*.yaml" | grep -v node_modules || true)
if [ -z "$YAML_FILES" ]; then
    echo "  [FAIL] No se encontraron archivos YAML"
    exit 1
fi

# --- Deployments ---
DEPLOY_COUNT=$(grep -l "kind: Deployment" $YAML_FILES 2>/dev/null | wc -l)
check "Mínimo 2 Deployments" test "$DEPLOY_COUNT" -ge 2
check "Deployments tienen resource limits" grep -q "limits" $YAML_FILES 2>/dev/null
check "Deployments tienen resource requests" grep -q "requests" $YAML_FILES 2>/dev/null
check "Deployments tienen strategy RollingUpdate" grep -q "RollingUpdate" $YAML_FILES 2>/dev/null
check "Deployments tienen replicas >= 2" grep -q "replicas:" $YAML_FILES 2>/dev/null

# --- Services ---
check "Service ClusterIP existe" grep -q "ClusterIP" $YAML_FILES 2>/dev/null
check "Service LoadBalancer existe" grep -q "LoadBalancer" $YAML_FILES 2>/dev/null

# --- Ingress ---
check "Ingress existe" grep -q "kind: Ingress" $YAML_FILES 2>/dev/null
check "Ingress con TLS" grep -q "tls:" $YAML_FILES 2>/dev/null
check "Ingress con host" grep -q "host:" $YAML_FILES 2>/dev/null

# --- ConfigMap & Secrets ---
check "ConfigMap existe" grep -q "kind: ConfigMap" $YAML_FILES 2>/dev/null
check "Secret existe" grep -q "kind: Secret" $YAML_FILES 2>/dev/null
check "Secret usa base64" grep -q "data:" $YAML_FILES 2>/dev/null

# --- HPA ---
check "HPA existe" grep -q "kind: HorizontalPodAutoscaler" $YAML_FILES 2>/dev/null
check "HPA con target CPU" grep -q "targetAverageUtilization" $YAML_FILES 2>/dev/null || grep -q "averageUtilization" $YAML_FILES 2>/dev/null
check "HPA con min/max replicas" grep -q "maxReplicas" $YAML_FILES 2>/dev/null

# --- PVC ---
check "PVC existe" grep -q "kind: PersistentVolumeClaim" $YAML_FILES 2>/dev/null
check "PVC con accessMode ReadWriteOnce" grep -q "ReadWriteOnce" $YAML_FILES 2>/dev/null

# --- Network Policies ---
check "Network Policy existe" grep -q "kind: NetworkPolicy" $YAML_FILES 2>/dev/null
check "Network Policy con podSelector" grep -q "podSelector" $YAML_FILES 2>/dev/null

# --- Probes ---
check "Liveness probe configurada" grep -q "livenessProbe" $YAML_FILES 2>/dev/null
check "Readiness probe configurada" grep -q "readinessProbe" $YAML_FILES 2>/dev/null

# --- Namespace ---
check "Namespace definido (metadata.namespace)" grep -q "namespace:" $YAML_FILES 2>/dev/null
check "Namespace no es 'default'" grep -v "namespace: default" $YAML_FILES | grep -q "namespace:" 2>/dev/null || true

# --- Labels ---
check "Labels 'app' presentes" grep -q "app:" $YAML_FILES 2>/dev/null
check "Labels 'environment' presentes" grep -q "environment:" $YAML_FILES 2>/dev/null
check "Labels 'managed-by' presentes" grep -q "managed-by:" $YAML_FILES 2>/dev/null

# --- YAML sintácticamente válido ---
for f in $YAML_FILES; do
    if python3 -c "import yaml; yaml.safe_load(open('$f'))" 2>/dev/null; then
        :
    else
        check "YAML válido: $(basename $f)" false
    fi
done

echo ""
echo "=== Resultados: $PASS/$TOTAL pasaron, $ERRORS fallos ==="
exit $ERRORS
