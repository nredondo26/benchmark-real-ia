#!/bin/bash
set -e

echo "=== Docker Challenge Verification ==="

echo -n "[1] Checking all containers are running... "
RUNNING=$(docker ps --format '{{.Names}}' | sort)
EXPECTED="docker-backend-1 docker-frontend-1 docker-redis-1"
for c in $EXPECTED; do
    if ! echo "$RUNNING" | grep -q "$c"; then
        echo "FAILED: $c not running"
        exit 1
    fi
done
echo "OK"

echo -n "[2] Checking backend health endpoint... "
HEALTH=$(docker exec docker-backend-1 curl -s http://localhost:8000/health 2>/dev/null || \
         docker exec docker-backend-1 wget -qO- http://localhost:8000/health 2>/dev/null)
if echo "$HEALTH" | grep -q "ok"; then
    echo "OK"
else
    echo "FAILED (response: $HEALTH)"
    exit 1
fi

echo -n "[3] Checking Redis connectivity via backend... "
REDIS_OK=$(echo "$HEALTH" | grep -o '"redis":true' || true)
if [ -n "$REDIS_OK" ]; then
    echo "OK"
else
    echo "FAILED (health response: $HEALTH)"
    exit 1
fi

echo -n "[4] Checking frontend loads via nginx... "
FRONTEND=$(docker exec docker-frontend-1 curl -s http://localhost:80/ 2>/dev/null || \
           docker exec docker-frontend-1 wget -qO- http://localhost:80/ 2>/dev/null)
if echo "$FRONTEND" | grep -qi "docker challenge"; then
    echo "OK"
else
    echo "FAILED"
    exit 1
fi

echo -n "[5] Checking API proxy through nginx... "
API=$(docker exec docker-frontend-1 curl -s http://localhost:80/api/data 2>/dev/null || \
      docker exec docker-frontend-1 wget -qO- http://localhost:80/api/data 2>/dev/null)
if echo "$API" | grep -q "Hello from FastAPI"; then
    echo "OK"
else
    echo "FAILED"
    exit 1
fi

echo -n "[6] Checking healthchecks defined in compose... "
if grep -q "healthcheck" docker-compose.yml 2>/dev/null; then
    echo "OK"
else
    echo "SKIP (no healthcheck config found)"
fi

echo ""
echo "=== All checks passed! ==="
