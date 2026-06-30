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

echo "=== Validación del reto Terraform ==="
echo ""

# --- Existencia de archivos clave ---
check "main.tf existe" test -f "$DIR/main.tf"
check "variables.tf existe" test -f "$DIR/variables.tf"
check "outputs.tf existe" test -f "$DIR/outputs.tf"
check "terraform.tfvars.example existe" test -f "$DIR/terraform.tfvars.example"
check "providers.tf existe" test -f "$DIR/providers.tf"

# --- Uso de módulos ---
check "Se usan módulos (terraform-modules)" grep -q 'module "' "$DIR/*.tf" 2>/dev/null || grep -q 'module "' "$DIR/modules/*/main.tf" 2>/dev/null

# --- Backend remoto ---
check "Backend S3 configurado" grep -q 'backend "s3"' "$DIR/providers.tf" 2>/dev/null || grep -q 'backend "s3"' "$DIR/main.tf" 2>/dev/null
check "DynamoDB state locking configurado" grep -q "dynamodb_table" "$DIR/providers.tf" 2>/dev/null || grep -q "dynamodb_table" "$DIR/main.tf" 2>/dev/null

# --- Recursos requeridos ---
check "Recurso VPC existe" grep -q 'resource "aws_vpc"' "$DIR/"*.tf 2>/dev/null
check "Subnet pública definida" grep -q 'resource "aws_subnet"' "$DIR/"*.tf 2>/dev/null && grep -q "public" "$DIR/"*.tf 2>/dev/null
check "Subnet privada definida" grep -q 'resource "aws_subnet"' "$DIR/"*.tf 2>/dev/null && grep -q "private" "$DIR/"*.tf 2>/dev/null
check "Auto Scaling Group existe" grep -q 'resource "aws_autoscaling_group"' "$DIR/"*.tf 2>/dev/null
check "Launch Template existe" grep -q 'resource "aws_launch_template"' "$DIR/"*.tf 2>/dev/null
check "RDS PostgreSQL existe" grep -q 'resource "aws_db_instance"' "$DIR/"*.tf 2>/dev/null
check "Engine PostgreSQL en RDS" grep -q "postgres" "$DIR/"*.tf 2>/dev/null
check "Bucket S3 existe" grep -q 'resource "aws_s3_bucket"' "$DIR/"*.tf 2>/dev/null
check "Versioning en S3 configurado" grep -q 'resource "aws_s3_bucket_versioning"' "$DIR/"*.tf 2>/dev/null
check "ALB existe" grep -q 'resource "aws_lb"' "$DIR/"*.tf 2>/dev/null || grep -q 'resource "aws_alb"' "$DIR/"*.tf 2>/dev/null
check "ALB Listener HTTPS existe" grep -q 'resource "aws_lb_listener".*https' "$DIR/"*.tf 2>/dev/null || grep -q 'protocol.*HTTPS' "$DIR/"*.tf 2>/dev/null
check "IAM Role existe" grep -q 'resource "aws_iam_role"' "$DIR/"*.tf 2>/dev/null
check "IAM Policy con least privilege" grep -q 'resource "aws_iam_policy"' "$DIR/"*.tf 2>/dev/null

# --- Variables tipadas ---
check "Variables tienen tipo definido" grep -q 'variable "' "$DIR/variables.tf" 2>/dev/null
check "Variables tienen descripción" grep -q "description" "$DIR/variables.tf" 2>/dev/null
check "Variables tienen type" grep -q "type" "$DIR/variables.tf" 2>/dev/null

# --- Outputs ---
check "Outputs definidos" grep -q 'output "' "$DIR/outputs.tf" 2>/dev/null

# --- Tags ---
check "Tags consistentes en recursos" grep -q "Proyecto" "$DIR/"*.tf 2>/dev/null
check "Tag Ambiente existe" grep -q "Ambiente" "$DIR/"*.tf 2>/dev/null

# --- NAT Gateway ---
check "NAT Gateway configurado" grep -q 'resource "aws_nat_gateway"' "$DIR/"*.tf 2>/dev/null

# --- Internet Gateway ---
check "Internet Gateway configurado" grep -q 'resource "aws_internet_gateway"' "$DIR/"*.tf 2>/dev/null

echo ""
echo "=== Resultados: $PASS/$TOTAL pasaron, $ERRORS fallos ==="
exit $ERRORS
