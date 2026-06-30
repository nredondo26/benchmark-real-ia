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

echo "=== Validación del reto AWS Serverless ==="
echo ""

# --- Detectar herramienta IaC ---
IAC_TOOL=""
if ls "$DIR"/*.tf 2>/dev/null | head -1 | grep -q .; then
    IAC_TOOL="terraform"
elif ls "$DIR"/template.yaml 2>/dev/null | head -1 | grep -q . || ls "$DIR"/*.yml 2>/dev/null | head -1 | grep -q .; then
    IAC_TOOL="sam"
elif ls "$DIR"/cdk.json 2>/dev/null | head -1 | grep -q . || ls "$DIR"/app.py 2>/dev/null | head -1 | grep -q . || ls "$DIR"/*.ts 2>/dev/null | head -1 | grep -q .; then
    IAC_TOOL="cdk"
fi

check "Herramienta IaC detectada (TF/SAM/CDK)" test -n "$IAC_TOOL"

# --- Estructura de archivos ---
if [ "$IAC_TOOL" = "terraform" ]; then
    check "main.tf existe" test -f "$DIR/main.tf"
    check "variables.tf existe" test -f "$DIR/variables.tf"
    check "outputs.tf existe" test -f "$DIR/outputs.tf"
elif [ "$IAC_TOOL" = "sam" ]; then
    check "template.yaml existe" test -f "$DIR/template.yaml"
elif [ "$IAC_TOOL" = "cdk" ]; then
    check "cdk.json existe" test -f "$DIR/cdk.json" -o -f "$DIR/cdk.json"
fi

# --- Recursos requeridos ---
# Buscar en todos los archivos IaC
SEARCH_FILES=$(find "$DIR" -maxdepth 2 \( -name "*.tf" -o -name "template.yaml" -o -name "*.ts" -o -name "*.py" -o -name "cdk.json" \) ! -path "*/node_modules/*" ! -path "*/cdk.out/*" 2>/dev/null || true)

if [ -n "$SEARCH_FILES" ]; then
    check "API Gateway definido" grep -qi "api_gateway\|aws_apigateway\|ApiGateway\|RestApi\|HttpApi" $SEARCH_FILES 2>/dev/null
    check "Cognito User Pool definido" grep -qi "cognito\|CognitoUserPool\|aws_cognito" $SEARCH_FILES 2>/dev/null
    check "Lambda function definida" grep -qi "lambda_function\|aws_lambda_function\|Function\|LambdaFunction" $SEARCH_FILES 2>/dev/null
    check "Step Functions definido" grep -qi "step_function\|aws_sfn_activity\|StateMachine\|StepFunctions" $SEARCH_FILES 2>/dev/null || grep -qi "StepFunctions\|sfn" $SEARCH_FILES 2>/dev/null
    check "DynamoDB definido" grep -qi "dynamodb\|aws_dynamodb_table\|Table\|DynamoDB" $SEARCH_FILES 2>/dev/null
    check "SQS definido" grep -qi "sqs\|aws_sqs_queue\|Queue" $SEARCH_FILES 2>/dev/null
    check "S3 bucket definido" grep -qi "s3_bucket\|aws_s3_bucket\|Bucket" $SEARCH_FILES 2>/dev/null
    check "CloudWatch Alarm definido" grep -qi "cloudwatch\|aws_cloudwatch_metric_alarm\|Alarm\|MetricFilter" $SEARCH_FILES 2>/dev/null
    check "Dead Letter Queue (DLQ) definida" grep -qi "dead_letter\|dlq\|RedrivePolicy\|DeadLetterConfig" $SEARCH_FILES 2>/dev/null
    check "GSI o LSI en DynamoDB" grep -qi "global_secondary_index\|local_secondary_index\|GSI\|LSI" $SEARCH_FILES 2>/dev/null
    check "Variables de entorno en Lambda" grep -qi "environment\|Variables" $SEARCH_FILES 2>/dev/null
fi

# --- Al menos 2 Lambdas ---
LAMBDA_COUNT=$(grep -c "lambda_function\|aws_lambda_function\|LambdaFunction\|Function" $SEARCH_FILES 2>/dev/null || echo 0)
check "Mínimo 2 Lambdas" test "$LAMBDA_COUNT" -ge 2 2>/dev/null || true

# --- Outputs ---
if [ "$IAC_TOOL" = "terraform" ]; then
    check "Outputs definidos" grep -q 'output "' "$DIR/outputs.tf" 2>/dev/null
fi

echo ""
echo "=== Resultados: $PASS/$TOTAL pasaron, $ERRORS fallos ==="
exit $ERRORS
