#!/usr/bin/env bash
# validate.sh - Validate that pipeline files exist and have correct structure
set -euo pipefail

PASS=0
FAIL=0

check() {
    local desc="$1"
    if [ $? -eq 0 ]; then
        echo "  ✅ PASS: $desc"
        PASS=$((PASS + 1))
    else
        echo "  ❌ FAIL: $desc"
        FAIL=$((FAIL + 1))
    fi
}

echo "=========================================="
echo "  CI/CD Pipeline Challenge - Validation"
echo "=========================================="
echo ""

# 1. App files exist
echo "[1] Application files"
test -f app/package.json
check "app/package.json exists"

test -f app/src/index.js
check "app/src/index.js exists"

test -f app/tests/app.test.js
check "app/tests/app.test.js exists"

# 2. Pipeline skeleton files exist
echo ""
echo "[2] Pipeline skeleton files"
test -f template/Jenkinsfile
check "template/Jenkinsfile exists"

test -f template/.github/workflows/deploy.yml
check "template/.github/workflows/deploy.yml exists"

# 3. Jenkinsfile structure
echo ""
echo "[3] Jenkinsfile structure"

grep -q "pipeline" template/Jenkinsfile
check "Jenkinsfile declares pipeline"

grep -q "stage.*Checkout" template/Jenkinsfile
check "Jenkinsfile has Checkout stage"

grep -q "stage.*Lint" template/Jenkinsfile
check "Jenkinsfile has Lint stage"

grep -q "stage.*Test" template/Jenkinsfile
check "Jenkinsfile has Test stage"

grep -q "stage.*Build" template/Jenkinsfile
check "Jenkinsfile has Build stage"

grep -q "stage.*Deploy" template/Jenkinsfile
check "Jenkinsfile has Deploy stage"

grep -q "when" template/Jenkinsfile
check "Jenkinsfile has when condition (deploy gate)"

grep -q "post" template/Jenkinsfile
check "Jenkinsfile has post section (notifications/rollback)"

grep -q "credentials\|secret" -i template/Jenkinsfile
check "Jenkinsfile references secret management"

# 4. GitHub Actions structure
echo ""
echo "[4] GitHub Actions structure"

grep -q "name:" template/.github/workflows/deploy.yml
check "deploy.yml has workflow name"

grep -q "on:" template/.github/workflows/deploy.yml
check "deploy.yml defines triggers"

grep -q "push" template/.github/workflows/deploy.yml
check "deploy.yml triggers on push"

grep -q "pull_request" template/.github/workflows/deploy.yml
check "deploy.yml triggers on pull_request"

grep -q "jobs:" template/.github/workflows/deploy.yml
check "deploy.yml defines jobs"

for job in lint test build deploy notify; do
    grep -q "$job" template/.github/workflows/deploy.yml
    check "deploy.yml has $job job"
done

grep -q "\${{ secrets\." template/.github/workflows/deploy.yml
check "deploy.yml references GitHub Secrets"

grep -q "cache\|actions/cache" template/.github/workflows/deploy.yml
check "deploy.yml references dependency caching"

grep -q "if.*failure\|failure()" template/.github/workflows/deploy.yml
check "deploy.yml has notification on failure"

# 5. README exists
echo ""
echo "[5] Documentation"
test -f README.md
check "README.md exists"

# Summary
echo ""
echo "=========================================="
echo "  Results: $PASS passed, $FAIL failed"
echo "=========================================="
exit $FAIL
