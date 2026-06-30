#!/bin/bash
# =============================================================================
# Results Watch — Live benchmark results viewer
# =============================================================================
# Uso:
#   ./scripts/results_watch.sh             # Mostrar últimos resultados
#   ./scripts/results_watch.sh --watch     # Seguir cambios en tiempo real
#   ./scripts/results_watch.sh --model gpt-4o  # Filtrar por modelo
#   ./scripts/results_watch.sh --help      # Mostrar ayuda
# =============================================================================

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
BASE_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
RESULTADOS_DIR="$BASE_DIR/resultados"

WATCH_MODE=false
MODEL_FILTER=""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

show_help() {
    sed -n '2,10p' "$0" | sed 's/^# //; s/^#//'
    exit 0
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --watch)    WATCH_MODE=true; shift ;;
        --model)    MODEL_FILTER="$2"; shift 2 ;;
        -h|--help)  show_help ;;
        *)          echo "Unknown option: $1"; show_help ;;
    esac
done

show_results() {
    printf "\033[2J\033[H"  # Clear screen

    echo -e "${CYAN}╔════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║           Benchmark Results Dashboard                         ║${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════════════════════════════╝${NC}"
    echo ""

    if [[ ! -d "$RESULTADOS_DIR" ]]; then
        echo -e "${YELLOW}No results directory found at $RESULTADOS_DIR${NC}"
        echo "Run a benchmark first with: ./scripts/runner.sh --model <model> --provider <provider> --key <key>"
        return
    fi

    local models=()
    if [[ -n "$MODEL_FILTER" ]]; then
        if [[ -d "$RESULTADOS_DIR/$MODEL_FILTER" ]]; then
            models=("$MODEL_FILTER")
        else
            echo -e "${RED}Model '$MODEL_FILTER' not found${NC}"
            return
        fi
    else
        for d in "$RESULTADOS_DIR"/*/; do
            [[ -d "$d" ]] && models+=("$(basename "$d")")
        done
    fi

    if [[ ${#models[@]} -eq 0 ]]; then
        echo -e "${YELLOW}No models found in $RESULTADOS_DIR${NC}"
        echo ""
        echo "Expected structure:"
        echo "  resultados/"
        echo "    <model>/"
        echo "      <challenge>/"
        echo "        metrics.json"
        echo "        response.json"
        echo "        solution/"
        return
    fi

    for model in "${models[@]}"; do
        echo -e "${BOLD}${BLUE}Model: ${model}${NC}"
        echo -e "${BLUE}$(printf '─%.0s' $(seq 1 60))${NC}"

        local model_dir="$RESULTADOS_DIR/$model"
        local challenges=()
        for d in "$model_dir"/*/; do
            [[ -d "$d" && -f "$d/metrics.json" ]] && challenges+=("$(basename "$d")")
        done

        if [[ ${#challenges[@]} -eq 0 ]]; then
            echo -e "  ${YELLOW}(no completed challenges)${NC}"
            echo ""
            continue
        fi

        # Header
        printf "  %-20s %-8s %-10s %-10s %-10s\n" "Challenge" "Score" "Time" "Cost" "Tests"
        printf "  %-20s %-8s %-10s %-10s %-10s\n" "$(printf '─%.0s' $(seq 1 20))" "$(printf '─%.0s' $(seq 1 8))" "$(printf '─%.0s' $(seq 1 10))" "$(printf '─%.0s' $(seq 1 10))" "$(printf '─%.0s' $(seq 1 10))"

        local total_score=0
        local total_time=0
        local total_cost=0
        local count=0

        for challenge in "${challenges[@]}"; do
            local metrics_file="$model_dir/$challenge/metrics.json"
            if [[ ! -f "$metrics_file" ]]; then
                continue
            fi

            local score="—"
            local time_str="—"
            local cost_str="—"
            local tests_str="—"
            local pass_color="$YELLOW"

            # Parse metrics with jq if available
            if command -v jq &>/dev/null; then
                local tiempo=$(jq -r '.metricas.tiempo_segundos // 0' "$metrics_file")
                local costo=$(jq -r '.metricas.costo_usd // 0' "$metrics_file")
                local pruebas=$(jq -r '.metricas.pruebas_superadas_pct // 0' "$metrics_file")
                local compila=$(jq -r '.metricas.compila // false' "$metrics_file")
                local calidad=$(jq -r '.metricas.calidad_1_10 // 0' "$metrics_file")
                local reto_name=$(jq -r '.reto // "'"$challenge"'"' "$metrics_file")

                # Format time
                if [[ "$tiempo" -gt 0 ]]; then
                    if [[ "$tiempo" -lt 60 ]]; then
                        time_str="${tiempo}s"
                    else
                        time_str="$((tiempo / 60))m $((tiempo % 60))s"
                    fi
                fi

                # Format cost
                if [[ "$(echo "$costo > 0" | bc 2>/dev/null)" == "1" ]] || [[ "$costo" != "0" ]]; then
                    cost_str=$(printf "\$%.4f" "$costo")
                fi

                # Format tests
                if [[ "$pruebas" -gt 0 ]]; then
                    tests_str="${pruebas}%"
                    if [[ "$pruebas" -ge 80 ]]; then
                        pass_color="$GREEN"
                    elif [[ "$pruebas" -ge 50 ]]; then
                        pass_color="$YELLOW"
                    else
                        pass_color="$RED"
                    fi
                fi

                # Calculate approximate score
                if [[ "$calidad" -gt 0 ]]; then
                    score=$(jq -n --argjson t "$tiempo" --argjson c "$costo" --argjson q "$calidad" \
                        --argjson p "$pruebas" --argjson comp "$compila" \
                        '{
                            tiempo_norm: (1 - (($t | tonumber) / (($t * 2) + 1))),
                            costo_norm: (1 - (($c | tonumber) / (($c * 2) + 0.1))),
                            calidad_norm: ($q / 10),
                            pruebas_norm: ($p / 100),
                            compila_val: (if $comp then 1 else 0 end)
                        } | .tiempo_norm * 0.15 + .costo_norm * 0.10 + .calidad_norm * 0.30 + .pruebas_norm * 0.10 + .compila_val * 0.10' 2>/dev/null)
                    if [[ -n "$score" ]]; then
                        score=$(printf "%.1f" "$(echo "$score * 100" | bc -l 2>/dev/null)")
                    fi
                fi

                total_time=$((total_time + tiempo))
                total_cost=$(echo "$total_cost + $costo" | bc -l 2>/dev/null || echo "0")
                count=$((count + 1))
            fi

            printf "  %-20s %-8s %-10s %-10s ${pass_color}%-10s${NC}\n" \
                "${challenge:0:20}" "$score" "$time_str" "$cost_str" "$tests_str"
        done

        # Totals row
        echo -e "  ${BLUE}$(printf '─%.0s' $(seq 1 60))${NC}"
        printf "  ${BOLD}%-20s %-8s %-10s %-10s %-10s${NC}\n" \
            "TOTAL" "" "$(printf '%ds' "$total_time")" "$(printf '$%.4f' "$total_cost")" ""

        echo ""
    done

    echo -e "${CYAN}Last updated: $(date '+%Y-%m-%d %H:%M:%S')${NC}"
    echo -e "${CYAN}Run './scripts/results_watch.sh --help' for options${NC}"
}

if [[ "$WATCH_MODE" == true ]]; then
    if command -v inotifywait &>/dev/null; then
        # Use inotify for efficient watching
        show_results
        while inotifywait -q -e create,modify,move -r "$RESULTADOS_DIR" 2>/dev/null; do
            show_results
        done
    elif command -v fswatch &>/dev/null; then
        # Fallback to fswatch
        show_results
        fswatch -0 "$RESULTADOS_DIR" | while read -d "" event; do
            show_results
        done
    else
        # Fallback to watch command
        echo -e "${YELLOW}inotifywait not found, using polling mode (5s interval)${NC}"
        echo -e "${YELLOW}Install inotify-tools for real-time updates: apt install inotify-tools${NC}"
        sleep 2
        while true; do
            show_results
            sleep 5
        done
    fi
else
    show_results
fi
