#!/bin/bash
# =============================================================================
# Benchmark Runner — Automated benchmark execution system
# =============================================================================
# Uso:
#   ./scripts/runner.sh --model gpt-4o --provider openai --key $KEY
#   ./scripts/runner.sh --model claude-3-opus --provider anthropic --key $KEY
#   ./scripts/runner.sh --model gemini-2.5-pro --provider google --key $KEY
#   ./scripts/runner.sh --model claude-3-sonnet --provider bedrock --key $KEY
#
# Opciones:
#   --model       Nombre del modelo (requerido)
#   --provider    Proveedor: openai, anthropic, google, bedrock (requerido)
#   --key         API key (requerido, o usar variable de entorno)
#   --reto        Ejecutar solo un reto específico (opcional)
#   --timeout     Timeout por llamada API en segundos (default: 120)
#   --all         Ejecutar todos los retos (default)
#   -h, --help    Muestra esta ayuda
# =============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
BASE_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
RETOS_DIR="$BASE_DIR/retos"
RESULTADOS_DIR="$BASE_DIR/resultados"
METRICAS_DIR="$BASE_DIR/metricas"
LOG_DIR="$BASE_DIR/logs"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# --- Defaults ---
MODEL=""
PROVIDER=""
API_KEY=""
RETO_FILTER=""
TIMEOUT=120
RUN_ALL=true

# --- Color output ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

log_info()  { echo -e "${BLUE}[INFO]${NC}  $*"; }
log_ok()    { echo -e "${GREEN}[OK]${NC}    $*"; }
log_warn()  { echo -e "${YELLOW}[WARN]${NC}  $*"; }
log_error() { echo -e "${RED}[ERROR]${NC} $*"; }
log_step()  { echo -e "\n${CYAN}════════════════════════════════════════════════════════════${NC}"; echo -e "${CYAN}  $*${NC}"; echo -e "${CYAN}════════════════════════════════════════════════════════════${NC}"; }

# --- Help ---
show_help() {
    sed -n '2,/^$/p' "$0" | sed 's/^# //; s/^#//'
    exit 0
}

# --- Parse arguments ---
while [[ $# -gt 0 ]]; do
    case "$1" in
        --model)     MODEL="$2"; shift 2 ;;
        --provider)  PROVIDER="$2"; shift 2 ;;
        --key)       API_KEY="$2"; shift 2 ;;
        --reto)      RETO_FILTER="$2"; RUN_ALL=false; shift 2 ;;
        --timeout)   TIMEOUT="$2"; shift 2 ;;
        --all)       RUN_ALL=true; shift ;;
        -h|--help)   show_help ;;
        *)           log_error "Unknown option: $1"; show_help ;;
    esac
done

# --- Validate ---
if [[ -z "$MODEL" ]]; then log_error "--model is required"; exit 1; fi
if [[ -z "$PROVIDER" ]]; then log_error "--provider is required"; exit 1; fi
if [[ -z "$API_KEY" ]]; then
    # Try environment variables
    case "$PROVIDER" in
        openai)    API_KEY="${OPENAI_API_KEY:-}" ;;
        anthropic) API_KEY="${ANTHROPIC_API_KEY:-}" ;;
        google)    API_KEY="${GOOGLE_API_KEY:-}" ;;
        bedrock)   API_KEY="${AWS_ACCESS_KEY_ID:-}" ;;
    esac
fi
if [[ -z "$API_KEY" ]]; then log_error "--key or env var is required for provider $PROVIDER"; exit 1; fi

# --- Directory setup ---
MODEL_DIR="$RESULTADOS_DIR/$MODEL"
mkdir -p "$MODEL_DIR" "$LOG_DIR"

# Log file
LOG_FILE="$LOG_DIR/runner_${MODEL}_${TIMESTAMP}.log"
exec > >(tee -a "$LOG_FILE") 2>&1

log_info "Benchmark runner started"
log_info "  Model:    $MODEL"
log_info "  Provider: $PROVIDER"
log_info "  Timeout:  ${TIMEOUT}s"
log_info "  Log file: $LOG_FILE"
log_info "  Directory: $MODEL_DIR"

# =============================================================================
# Provider API call functions
# =============================================================================

call_openai() {
    local prompt="$1"
    local model="$2"
    curl -s -w "\n%{http_code}" --max-time "$TIMEOUT" https://api.openai.com/v1/chat/completions \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer $API_KEY" \
        -d "$(jq -n --arg model "$model" --arg prompt "$prompt" '{
            model: $model,
            messages: [{"role": "user", "content": $prompt}],
            max_tokens: 8192
        }')"
}

call_anthropic() {
    local prompt="$1"
    local model="$2"
    curl -s -w "\n%{http_code}" --max-time "$TIMEOUT" https://api.anthropic.com/v1/messages \
        -H "Content-Type: application/json" \
        -H "x-api-key: $API_KEY" \
        -H "anthropic-version: 2023-06-01" \
        -d "$(jq -n --arg model "$model" --arg prompt "$prompt" '{
            model: $model,
            max_tokens: 8192,
            messages: [{"role": "user", "content": $prompt}]
        }')"
}

call_google() {
    local prompt="$1"
    local model="$2"
    local url="https://generativelanguage.googleapis.com/v1beta/models/${model}:generateContent?key=${API_KEY}"
    curl -s -w "\n%{http_code}" --max-time "$TIMEOUT" "$url" \
        -H "Content-Type: application/json" \
        -d "$(jq -n --arg prompt "$prompt" '{
            contents: [{"parts": [{"text": $prompt}]}]
        }')"
}

call_bedrock() {
    local prompt="$1"
    local model="$2"
    # AWS Bedrock requires AWS CLI with configured credentials
    local region="${AWS_REGION:-us-east-1}"
    local body
    body=$(jq -n --arg prompt "$prompt" '{
        anthropic_version: "bedrock-2023-05-31",
        max_tokens: 8192,
        messages: [{"role": "user", "content": $prompt}]
    }')
    local result
    result=$(aws bedrock-runtime invoke-model \
        --model-id "$model" \
        --body "$body" \
        --region "$region" \
        /dev/stdout 2>/dev/null || echo '{"error":"AWS CLI call failed"}')
    echo "$result"
    # Bedrock always returns 200 from aws CLI perspective
    echo "200"
}

call_provider() {
    local provider="$1"
    local model="$2"
    local prompt="$3"

    case "$provider" in
        openai)    call_openai "$prompt" "$model" ;;
        anthropic) call_anthropic "$prompt" "$model" ;;
        google)    call_google "$prompt" "$model" ;;
        bedrock)   call_bedrock "$prompt" "$model" ;;
        *)         log_error "Unknown provider: $provider"; return 1 ;;
    esac
}

# =============================================================================
# Prompt building
# =============================================================================

build_prompt() {
    local reto="$1"
    local reto_dir="$RETOS_DIR/$reto"
    local prompt=""

    # Try scripts/prompts/{reto}.md first
    local prompt_file="$SCRIPT_DIR/prompts/${reto}.md"
    if [[ -f "$prompt_file" ]]; then
        prompt=$(cat "$prompt_file")
    else
        # Fall back to reto's README.md
        if [[ -f "$reto_dir/README.md" ]]; then
            prompt="$(cat "$reto_dir/README.md")"
        fi
    fi

    # Append spec files if they exist
    if [[ -f "$reto_dir/spec.yaml" ]]; then
        prompt+="\n\n## OpenAPI Spec\n\n"
        prompt+="$(cat "$reto_dir/spec.yaml")"
    fi

    if [[ -f "$reto_dir/specs/requirements.md" ]]; then
        prompt+="\n\n## Requirements\n\n"
        prompt+="$(cat "$reto_dir/specs/requirements.md")"
    fi

    # Append template files if they exist
    local template_dir="$reto_dir/template"
    if [[ -d "$template_dir" ]]; then
        prompt+="\n\n## Template Files\n\n"
        while IFS= read -r -d '' tf; do
            local rel="${tf#$template_dir/}"
            prompt+="### ${rel}\n\n\`\`\`\n$(cat "$tf")\n\`\`\`\n\n"
        done < <(find "$template_dir" -type f -print0)
    fi

    # Append spec files from specs/ directory
    local specs_dir="$reto_dir/specs"
    if [[ -d "$specs_dir" ]]; then
        while IFS= read -r -d '' sf; do
            local rel="${sf#$specs_dir/}"
            prompt+="\n\n## Spec: ${rel}\n\n\`\`\`\n$(cat "$sf")\n\`\`\`\n\n"
        done < <(find "$specs_dir" -type f -print0)
    fi

    echo -e "$prompt"
}

# =============================================================================
# Cost calculation
# =============================================================================

calculate_cost() {
    local provider="$1"
    local prompt_tokens="$2"
    local completion_tokens="$3"

    # Approximate pricing per 1K tokens (USD)
    case "$provider" in
        openai)
            # GPT-4o pricing
            local input_price=0.0025
            local output_price=0.010
            # GPT-4
            if echo "$MODEL" | grep -qi "gpt-4-"; then
                input_price=0.030
                output_price=0.060
            fi
            ;;
        anthropic)
            # Claude 3 Opus
            local input_price=0.015
            local output_price=0.075
            # Claude 3 Sonnet
            if echo "$MODEL" | grep -qi "sonnet"; then
                input_price=0.003
                output_price=0.015
            fi
            # Claude 3.5 Sonnet / Haiku
            if echo "$MODEL" | grep -qi "haiku"; then
                input_price=0.00025
                output_price=0.00125
            fi
            ;;
        google)
            # Gemini 1.5 Pro
            local input_price=0.0035
            local output_price=0.0105
            # Gemini 1.5 Flash
            if echo "$MODEL" | grep -qi "flash"; then
                input_price=0.00035
                output_price=0.00105
            fi
            ;;
        bedrock)
            local input_price=0.003
            local output_price=0.015
            ;;
        *) local input_price=0.001; local output_price=0.002 ;;
    esac

    local cost=$(echo "scale=6; ($prompt_tokens * $input_price + $completion_tokens * $output_price) / 1000" | bc)
    printf "%.6f" "$cost"
}

# =============================================================================
# Token counting (approximate)
# =============================================================================

count_tokens() {
    local text="$1"
    # Rough estimate: 1 token ≈ 4 characters for English text
    echo $(( ${#text} / 4 ))
}

# =============================================================================
# Test execution
# =============================================================================

run_tests() {
    local reto="$1"
    local solution_dir="$2"
    local reto_dir="$RETOS_DIR/$reto"
    local results=""
    local pass_count=0
    local total_count=0

    log_info "Running tests for $reto..."

    # Determine test type and run accordingly
    if [[ -f "$reto_dir/tests/verify.sh" ]]; then
        # Shell-based verification
        log_info "  Test type: shell script"
        if [[ -x "$reto_dir/tests/verify.sh" ]]; then
            results=$(cd "$reto_dir" && bash "$reto_dir/tests/verify.sh" 2>&1) || true
        else
            results=$(cd "$reto_dir" && bash "$reto_dir/tests/verify.sh" 2>&1) || true
        fi
        pass_count=$(echo "$results" | grep -c "OK\|PASS\|SUCCESS" || echo "0")
        total_count=$(echo "$results" | grep -cE "\[[0-9]\]" || echo "$pass_count")
        if [[ -z "$total_count" || "$total_count" -eq 0 ]]; then
            total_count=1
            if echo "$results" | grep -qi "all checks passed\|success\|ok"; then
                pass_count=1
            fi
        fi

    elif [[ -f "$reto_dir/tests/validate.sh" ]]; then
        # Shell-based validation
        log_info "  Test type: validation script"
        results=$(cd "$reto_dir" && bash "$reto_dir/tests/validate.sh" 2>&1) || true
        pass_count=$(echo "$results" | grep -c "OK\|PASS\|SUCCESS\|VALID" || echo "0")
        total_count=$(echo "$results" | grep -cE "\[[0-9]\]|✓|PASS" || echo "1")

    elif [[ -f "$reto_dir/tests/test_app.py" || -f "$reto_dir/tests/test_api.py" ]]; then
        # Python pytest
        log_info "  Test type: pytest"
        local test_file=""
        if [[ -f "$reto_dir/tests/test_app.py" ]]; then test_file="$reto_dir/tests/test_app.py"; fi
        if [[ -f "$reto_dir/tests/test_api.py" ]]; then test_file="$reto_dir/tests/test_api.py"; fi

        # Copy solution files to reto directory for testing
        if [[ -d "$solution_dir" ]]; then
            cp -r "$solution_dir"/* "$reto_dir/" 2>/dev/null || true
        fi

        results=$(cd "$reto_dir" && python -m pytest "$test_file" -v 2>&1) || true
        pass_count=$(echo "$results" | grep -c "PASSED\|passed" || echo "0")
        local failed_count=$(echo "$results" | grep -c "FAILED\|failed" || echo "0")
        total_count=$((pass_count + failed_count))
        if [[ "$total_count" -eq 0 ]]; then
            # Try to get from summary line
            local summary=$(echo "$results" | grep -oP '\d+ passed' | head -1 | grep -oP '\d+')
            if [[ -n "$summary" ]]; then
                pass_count=$summary
                total_count=$summary
            fi
        fi

    elif [[ -f "$reto_dir/tests/verify.sql" ]]; then
        # SQL verification
        log_info "  Test type: SQL verification"
        results=$(cd "$reto_dir" && python -c "
import subprocess, sys, os
# Apply migration if exists
if os.path.exists('$solution_dir/migrate.sql'):
    subprocess.run(['sqlite3', 'ecommerce.db'], input=open('$solution_dir/migrate.sql').read(), text=True, capture_output=True)
# Run verify
r = subprocess.run(['sqlite3', 'ecommerce.db'], input=open('tests/verify.sql').read(), text=True, capture_output=True)
print(r.stdout)
print(r.stderr)
" 2>&1) || true
        pass_count=$(echo "$results" | grep -ciE "ok|pass|correcto|✓" || echo "0")
        total_count=$(echo "$results" | grep -cE "^\[|✓" || echo "1")

    elif [[ -f "$reto_dir/tests/checklist.md" ]]; then
        # Checklist-based: just log it (manual evaluation)
        log_info "  Test type: checklist (manual evaluation)"
        results="Checklist-based evaluation required. See: tests/checklist.md"
        pass_count=0
        total_count=0
    else
        log_warn "  No tests found for $reto"
        results="No tests available"
        pass_count=0
        total_count=0
    fi

    # Calculate pass percentage
    local pct=0
    if [[ "$total_count" -gt 0 ]]; then
        pct=$(( pass_count * 100 / total_count ))
    fi

    echo "PASS=$pass_count TOTAL=$total_count PCT=$pct"
    echo "---RESULTS---"
    echo "$results"
}

# =============================================================================
# Metrics saving
# =============================================================================

save_metrics() {
    local reto="$1"
    local time_seconds="$2"
    local cost_usd="$3"
    local prompt_tokens="$4"
    local completion_tokens="$5"
    local test_passed="$6"
    local test_total="$7"
    local test_pct="$8"
    local response_file="$9"

    local reto_dir="$MODEL_DIR/$reto"
    mkdir -p "$reto_dir"

    local metrics_file="$reto_dir/metrics.json"

    local compila=false
    if [[ "$test_total" -gt 0 && "$test_passed" -eq "$test_total" ]]; then
        compila=true
    fi

    jq -n \
        --arg modelo "$MODEL" \
        --arg reto "$reto" \
        --arg fecha "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
        --argjson tiempo "$time_seconds" \
        --argjson costo "$cost_usd" \
        --argjson calidad 0 \
        --argjson errores 0 \
        --argjson alucinaciones 0 \
        --argjson lineas 0 \
        --argjson compila "$compila" \
        --argjson pruebas "$test_pct" \
        --argjson prompt_tokens "$prompt_tokens" \
        --argjson completion_tokens "$completion_tokens" \
        '{
            modelo: $modelo,
            reto: $reto,
            fecha: $fecha,
            metricas: {
                tiempo_segundos: $tiempo,
                costo_usd: $costo,
                calidad_1_10: $calidad,
                errores: $errores,
                alucinaciones: $alucinaciones,
                lineas_modificadas: $lineas,
                compila: $compila,
                pruebas_superadas_pct: $pruebas
            },
            tokens: {
                prompt: $prompt_tokens,
                completion: $completion_tokens,
                total: ($prompt_tokens + $completion_tokens)
            },
            observaciones: "",
            evaluador: "runner.sh"
        }' > "$metrics_file"

    log_ok "Metrics saved to $metrics_file"
}

# =============================================================================
# Report generation
# =============================================================================

generate_report() {
    log_step "Generating final report..."
    if [[ -f "$SCRIPT_DIR/generate_report.py" ]]; then
        python "$SCRIPT_DIR/generate_report.py" "$MODEL_DIR" 2>&1 || log_warn "Report generation had issues"
    fi
}

# =============================================================================
# Main execution
# =============================================================================

main() {
    local challenges=()
    local total_time=0
    local total_cost=0
    local overall_pass=0
    local overall_total=0

    # Determine which challenges to run
    if [[ "$RUN_ALL" == true ]]; then
        for d in "$RETOS_DIR"/*/; do
            challenges+=("$(basename "$d")")
        done
    else
        if [[ -d "$RETOS_DIR/$RETO_FILTER" ]]; then
            challenges+=("$RETO_FILTER")
        else
            log_error "Challenge '$RETO_FILTER' not found in $RETOS_DIR"
            exit 1
        fi
    fi

    log_info "Challenges to run: ${#challenges[@]}"
    for c in "${challenges[@]}"; do
        log_info "  - $c"
    done

    # Run each challenge
    for reto in "${challenges[@]}"; do
        local reto_dir="$RETOS_DIR/$reto"
        local reto_result_dir="$MODEL_DIR/$reto"

        log_step "Challenge: $reto"

        # 1. Build prompt
        local prompt
        prompt=$(build_prompt "$reto")
        log_info "Prompt built (${#prompt} characters)"

        # 2. Call the model API
        log_info "Calling $PROVIDER/$MODEL..."
        local start_time
        start_time=$(date +%s)

        local response_and_code
        response_and_code=$(call_provider "$PROVIDER" "$MODEL" "$prompt" 2>&1)

        local end_time
        end_time=$(date +%s)
        local elapsed=$(( end_time - start_time ))

        # Split response body and HTTP status code
        local http_code="${response_and_code##*$'\n'}"
        local response_body="${response_and_code%$'\n'*}"

        # For bedrock, http_code is always 200 (appended by the function)
        if [[ "$PROVIDER" == "bedrock" ]]; then
            response_body="$response_and_code"
            http_code="200"
        fi

        log_info "API response received (HTTP $http_code, ${elapsed}s)"

        # 3. Save raw response
        mkdir -p "$reto_result_dir"
        echo "$response_body" > "$reto_result_dir/response.json"

        # 4. Extract tokens from response
        local prompt_tokens=0
        local completion_tokens=0
        prompt_tokens=$(echo "$response_body" | jq -r '.usage.prompt_tokens // .usage.input_tokens // 0' 2>/dev/null)
        completion_tokens=$(echo "$response_body" | jq -r '.usage.completion_tokens // .usage.output_tokens // 0' 2>/dev/null)

        # Fallback token counting
        if [[ "$prompt_tokens" -eq 0 ]]; then
            prompt_tokens=$(count_tokens "$prompt")
        fi
        if [[ "$completion_tokens" -eq 0 ]]; then
            local response_text
            response_text=$(echo "$response_body" | python3 -c "
import sys, json
data = json.load(sys.stdin)
if 'choices' in data and data['choices']:
    print(data['choices'][0].get('message', {}).get('content', '') or data['choices'][0].get('text', ''))
elif 'content' in data:
    if isinstance(data['content'], list):
        for b in data['content']:
            if isinstance(b, dict) and b.get('type') == 'text':
                print(b.get('text', ''), end='')
    else:
        print(data['content'])
elif 'candidates' in data:
    for c in data['candidates']:
        for p in c.get('content', {}).get('parts', []):
            print(p.get('text', ''), end='')
else:
    print(json.dumps(data))
" 2>/dev/null || echo "")
            completion_tokens=$(count_tokens "$response_text")
        fi

        # 5. Calculate cost
        local cost
        cost=$(calculate_cost "$PROVIDER" "$prompt_tokens" "$completion_tokens")

        # 6. Extract code from response
        log_info "Extracting code..."
        local solution_dir="$reto_result_dir/solution"
        mkdir -p "$solution_dir"
        python3 "$SCRIPT_DIR/extract_code.py" "$reto_result_dir/response.json" "$solution_dir" 2>&1 || log_warn "Code extraction had issues"

        # 7. Run tests
        log_info "Running tests..."
        local test_output
        test_output=$(run_tests "$reto" "$solution_dir")
        local test_pass test_total test_pct
        test_pass=$(echo "$test_output" | grep "^PASS=" | head -1 | cut -d= -f2)
        test_total=$(echo "$test_output" | grep "^TOTAL=" | head -1 | cut -d= -f2)
        test_pct=$(echo "$test_output" | grep "^PCT=" | head -1 | cut -d= -f2)
        test_pass=${test_pass:-0}
        test_total=${test_total:-0}
        test_pct=${test_pct:-0}

        # Save test output
        echo "$test_output" > "$reto_result_dir/test_output.log"

        # 8. Save metrics
        save_metrics "$reto" "$elapsed" "$cost" "$prompt_tokens" "$completion_tokens" \
            "$test_pass" "$test_total" "$test_pct" "$reto_result_dir/response.json"

        # 9. Accumulate totals
        total_time=$(( total_time + elapsed ))
        total_cost=$(echo "scale=6; $total_cost + $cost" | bc)
        overall_pass=$(( overall_pass + test_pass ))
        overall_total=$(( overall_total + test_total ))

        # Print summary
        log_info "Results for $reto:"
        log_info "  Time: ${elapsed}s | Cost: \$${cost} | Tests: ${test_pass}/${test_total} (${test_pct}%)"
        log_info "  Response:  $reto_result_dir/response.json"
        log_info "  Solution:  $solution_dir"

        # Safety delay between API calls
        sleep 1
    done

    # Generate final report
    generate_report

    # Print overall summary
    log_step "Benchmark Complete"
    log_info "  Model:       $MODEL"
    log_info "  Provider:    $PROVIDER"
    log_info "  Total time:  ${total_time}s"
    log_info "  Total cost:  \$${total_cost}"
    if [[ "$overall_total" -gt 0 ]]; then
        local overall_pct=$(( overall_pass * 100 / overall_total ))
        log_info "  Overall:     ${overall_pass}/${overall_total} tests passed (${overall_pct}%)"
    fi
    log_info "  Report:      $MODEL_DIR/REPORT.md"
    log_info "  Log:         $LOG_FILE"
    log_info "Done."
}

main "$@"
