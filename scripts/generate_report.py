#!/usr/bin/env python3
"""
Generate a comprehensive benchmark report from results.

Reads a model's results directory and produces a Markdown report with:
- Summary table
- Per-challenge scores, times, costs, test results
- Overall statistics
- Cross-model comparison if multiple models exist

Usage:
    ./scripts/generate_report.py resultados/gpt-4o
    ./scripts/generate_report.py resultados/  (compares all models)
"""

import json
import os
import re
import sys
from collections import defaultdict
from datetime import datetime
from pathlib import Path


# Scoring weights (matching metricas/README.md)
WEIGHTS = {
    "tiempo_segundos": 0.15,
    "costo_usd": 0.10,
    "calidad_1_10": 0.30,
    "errores": 0.15,
    "alucinaciones": 0.10,
    "compila": 0.10,
    "pruebas_superadas_pct": 0.10,
}


def load_metrics(metrics_file):
    """Load a metrics.json file."""
    with open(metrics_file) as f:
        return json.load(f)


def load_response(response_file):
    """Load a response.json file."""
    with open(response_file) as f:
        return json.load(f)


def normalize(value, best, worst):
    """Normalize a value between 0 and 1 (higher is better)."""
    if worst == best:
        return 1.0
    return max(0, min(1, 1 - (value - best) / (worst - best)))


def calculate_score(data, best_times=None, best_costs=None):
    """Calculate overall score using the metricas scoring system."""
    if best_times is None:
        best_times = {}
    if best_costs is None:
        best_costs = {}

    m = data.get("metricas", data)

    tiempo = m.get("tiempo_segundos", 0)
    costo = m.get("costo_usd", 0)
    calidad = m.get("calidad_1_10", 0)
    errores = m.get("errores", 0)
    alucinaciones = m.get("alucinaciones", 0)
    compila = m.get("compila", False)
    pruebas = m.get("pruebas_superadas_pct", 0)

    reto_nombre = data.get("reto", "unknown")

    best_time = best_times.get(reto_nombre, 0)
    best_cost = best_costs.get(reto_nombre, 0)

    tiempo_norm = normalize(tiempo, best_time, max(tiempo * 2, best_time * 2, 1))
    costo_norm = normalize(costo, best_cost, max(costo * 2, best_cost * 2, 0.01))
    calidad_norm = calidad / 10.0
    errores_penalty = max(0, 1 - errores * 0.03)
    alucinaciones_penalty = max(0, 1 - alucinaciones * 0.05)
    compila_val = 1.0 if compila else 0.0
    pruebas_norm = pruebas / 100.0

    score = (
        tiempo_norm * WEIGHTS["tiempo_segundos"]
        + costo_norm * WEIGHTS["costo_usd"]
        + calidad_norm * WEIGHTS["calidad_1_10"]
        + errores_penalty * WEIGHTS["errores"]
        + alucinaciones_penalty * WEIGHTS["alucinaciones"]
        + compila_val * WEIGHTS["compila"]
        + pruebas_norm * WEIGHTS["pruebas_superadas_pct"]
    )

    return round(score * 100, 2)


def discover_challenges(model_dir):
    """Discover all challenge subdirectories in a model's results directory."""
    challenges = []
    model_path = Path(model_dir)
    if not model_path.exists():
        return challenges
    for item in model_path.iterdir():
        if item.is_dir() and item.name != "solution":
            metrics_file = item / "metrics.json"
            response_file = item / "response.json"
            if metrics_file.exists():
                challenges.append({
                    "name": item.name,
                    "metrics_file": metrics_file,
                    "response_file": response_file if response_file.exists() else None,
                    "dir": item,
                })
    return sorted(challenges, key=lambda c: c["name"])


def discover_models(resultados_dir):
    """Discover all model directories."""
    models = []
    resultados_path = Path(resultados_dir)
    if not resultados_path.exists():
        return models
    for item in resultados_path.iterdir():
        if item.is_dir():
            challenges = discover_challenges(item)
            if challenges:
                models.append({
                    "name": item.name,
                    "dir": item,
                    "challenges": challenges,
                })
    return sorted(models, key=lambda m: m["name"])


def read_extracted_files(solution_dir):
    """Read all files in the solution directory."""
    result = {}
    sol_path = Path(solution_dir)
    if not sol_path.exists():
        return result
    for f in sorted(sol_path.iterdir()):
        if f.is_file():
            try:
                result[f.name] = f.read_text()
            except Exception:
                result[f.name] = "[binary or unreadable]"
    return result


def format_elapsed(seconds):
    """Format seconds into human-readable string."""
    if seconds < 60:
        return f"{seconds}s"
    minutes = seconds // 60
    secs = seconds % 60
    if minutes < 60:
        return f"{minutes}m {secs}s"
    hours = minutes // 60
    mins = minutes % 60
    return f"{hours}h {mins}m {secs}s"


def score_to_grade(score):
    """Convert a numerical score to a letter grade."""
    if score >= 90:
        return "A"
    elif score >= 80:
        return "B"
    elif score >= 70:
        return "C"
    elif score >= 60:
        return "D"
    else:
        return "F"


def generate_single_model_report(model_info):
    """Generate a report for a single model."""
    model_name = model_info["name"]
    challenges = model_info["challenges"]

    lines = []
    lines.append(f"# Benchmark Report: {model_name}")
    lines.append("")
    lines.append(f"**Generated:** {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    lines.append("")

    if not challenges:
        lines.append("No results found.")
        return "\n".join(lines)

    # Calculate best times and costs for normalization
    best_times = {}
    best_costs = {}
    for c in challenges:
        try:
            data = load_metrics(c["metrics_file"])
            m = data.get("metricas", data)
            reto = data.get("reto", c["name"])
            if reto not in best_times or m.get("tiempo_segundos", 0) < best_times[reto]:
                best_times[reto] = m.get("tiempo_segundos", 0)
            if reto not in best_costs or m.get("costo_usd", 0) < best_costs[reto]:
                best_costs[reto] = m.get("costo_usd", 0)
        except (json.JSONDecodeError, KeyError):
            pass

    # Calculate scores for each challenge
    challenge_data = []
    total_time = 0
    total_cost = 0.0
    total_tests_passed = 0
    total_tests = 0
    total_tokens = 0

    for c in challenges:
        try:
            data = load_metrics(c["metrics_file"])
            m = data.get("metricas", data)
            score = calculate_score(data, best_times, best_costs)

            reto_name = data.get("reto", c["name"])
            tiempo = m.get("tiempo_segundos", 0)
            costo = m.get("costo_usd", 0)
            pruebas = m.get("pruebas_superadas_pct", 0)
            calidad = m.get("calidad_1_10", 0)
            compila = m.get("compila", False)

            tokens = data.get("tokens", {})
            prompt_t = tokens.get("prompt", 0)
            completion_t = tokens.get("completion", 0)
            total_t = tokens.get("total", prompt_t + completion_t)

            total_time += tiempo
            total_cost += costo
            total_tokens += total_t

            # Count tests if we can parse them
            test_log = c["dir"] / "test_output.log"
            if test_log.exists():
                content = test_log.read_text()
                m_pass = re.search(r"PASS=(\d+)", content)
                m_total = re.search(r"TOTAL=(\d+)", content)
                if m_pass and m_total:
                    total_tests_passed += int(m_pass.group(1))
                    total_tests += int(m_total.group(1))

            challenge_data.append({
                "name": reto_name,
                "score": score,
                "tiempo": tiempo,
                "costo": costo,
                "pruebas": pruebas,
                "calidad": calidad,
                "compila": compila,
                "tokens": total_t,
                "grade": score_to_grade(score),
            })
        except (json.JSONDecodeError, KeyError, FileNotFoundError) as e:
            challenge_data.append({
                "name": c["name"],
                "score": 0,
                "tiempo": 0,
                "costo": 0,
                "pruebas": 0,
                "calidad": 0,
                "compila": False,
                "tokens": 0,
                "grade": "F",
                "error": str(e),
            })

    # Summary table
    lines.append("## Summary")
    lines.append("")
    lines.append("| Challenge | Score | Grade | Time | Cost | Tests | Quality | Compiles |")
    lines.append("|-----------|-------|-------|------|------|-------|---------|----------|")

    avg_score = 0
    for cd in challenge_data:
        avg_score += cd["score"]
        tests_str = f"{cd['pruebas']:.0f}%" if cd["pruebas"] > 0 else "N/A"
        quality_str = f"{cd['calidad']}/10" if cd["calidad"] > 0 else "N/A"
        compila_str = "✅" if cd["compila"] else "❌"
        cost_str = f"${cd['costo']:.4f}" if cd["costo"] > 0 else "—"
        time_str = format_elapsed(cd["tiempo"]) if cd["tiempo"] > 0 else "—"
        lines.append(
            f"| {cd['name']} | {cd['score']:.2f} | {cd['grade']} "
            f"| {time_str} | {cost_str} "
            f"| {tests_str} | {quality_str} | {compila_str} |"
        )

    avg_score = avg_score / len(challenge_data) if challenge_data else 0

    lines.append("")
    lines.append(f"**Average Score: {avg_score:.2f}/100 ({score_to_grade(avg_score)})**")
    lines.append(f"**Total Time: {format_elapsed(total_time)}**")
    lines.append(f"**Total Cost: ${total_cost:.4f}**")
    lines.append(f"**Total Tokens: {total_tokens:,}**")

    if total_tests > 0:
        pass_pct = total_tests_passed * 100 / total_tests
        lines.append(f"**Overall Tests: {total_tests_passed}/{total_tests} ({pass_pct:.1f}%)**")

    lines.append("")

    # Per-challenge details
    lines.append("## Detailed Results")
    lines.append("")

    for cd in challenge_data:
        lines.append(f"### {cd['name']}")
        lines.append("")
        lines.append(f"- **Score:** {cd['score']:.2f}/100 ({cd['grade']})")
        lines.append(f"- **Time:** {format_elapsed(cd['tiempo'])}")
        lines.append(f"- **Cost:** ${cd['costo']:.4f}")
        lines.append(f"- **Tests:** {cd['pruebas']:.0f}%" if cd['pruebas'] > 0 else "- **Tests:** N/A")
        lines.append(f"- **Quality:** {cd['calidad']}/10" if cd['calidad'] > 0 else "- **Quality:** N/A")
        lines.append(f"- **Compiles:** {'Yes' if cd['compila'] else 'No'}")
        if cd.get("tokens"):
            lines.append(f"- **Tokens:** {cd['tokens']:,}")
        if cd.get("error"):
            lines.append(f"- **Error:** {cd['error']}")
        lines.append("")

        # Show extracted files
        for challenge_dir in challenges:
            if challenge_dir["name"] == cd["name"]:
                sol_dir = challenge_dir["dir"] / "solution"
                files = read_extracted_files(sol_dir)
                if files:
                    lines.append("**Generated Files:**")
                    for fname, fcontent in files.items():
                        lines.append(f"- `{fname}` ({len(fcontent)} bytes)")
                    lines.append("")
                break

    # Scoring section
    lines.append("## Scoring System")
    lines.append("")
    lines.append("| Metric | Weight | Description |")
    lines.append("|--------|--------|-------------|")
    lines.append("| Time | 15% | Normalized against best time |")
    lines.append("| Cost | 10% | Normalized against best cost |")
    lines.append("| Quality | 30% | Human evaluation (1-10) |")
    lines.append("| Errors | 15% | Penalty per error (-3%) |")
    lines.append("| Hallucinations | 10% | Penalty per hallucination (-5%) |")
    lines.append("| Compilation | 10% | Binary: 0 or 100 |")
    lines.append("| Tests | 10% | Percentage of tests passed |")
    lines.append("")

    return "\n".join(lines)


def generate_comparison_report(modelos_path):
    """Generate a cross-model comparison report."""
    models = discover_models(modelos_path)

    if len(models) < 1:
        return "No models found in resultados/"

    lines = []
    lines.append("# Cross-Model Comparison Report")
    lines.append("")
    lines.append(f"**Generated:** {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    lines.append(f"**Models compared:** {len(models)}")
    lines.append("")

    # Collect all challenge names
    all_challenges = set()
    for m in models:
        for c in m["challenges"]:
            all_challenges.add(c["name"])
    all_challenges = sorted(all_challenges)

    # Collect all scores per model per challenge
    model_scores = {}
    model_times = {}
    model_costs = {}

    for m in models:
        scores = {}
        times = {}
        costs = {}
        for c in m["challenges"]:
            try:
                data = load_metrics(c["metrics_file"])
                met = data.get("metricas", data)
                scores[c["name"]] = {
                    "score": calculate_score(data),
                    "tiempo": met.get("tiempo_segundos", 0),
                    "costo": met.get("costo_usd", 0),
                    "pruebas": met.get("pruebas_superadas_pct", 0),
                }
                times[c["name"]] = met.get("tiempo_segundos", 0)
                costs[c["name"]] = met.get("costo_usd", 0)
            except Exception:
                scores[c["name"]] = {"score": 0, "tiempo": 0, "costo": 0, "pruebas": 0}
                times[c["name"]] = 0
                costs[c["name"]] = 0
        model_scores[m["name"]] = scores
        model_times[m["name"]] = times
        model_costs[m["name"]] = costs

    # Comparison table
    lines.append("## Per-Challenge Scores")
    lines.append("")
    header = "| Challenge |"
    separator = "|-----------|"
    for m in models:
        header += f" {m['name']} |"
        separator += "--------|"
    lines.append(header)
    lines.append(separator)

    for ch in all_challenges:
        row = f"| {ch} |"
        for m in models:
            s = model_scores.get(m["name"], {}).get(ch, {}).get("score", 0)
            row += f" {s:.2f} |"
        lines.append(row)

    lines.append("")

    # Time comparison
    lines.append("## Time Comparison (seconds)")
    lines.append("")
    header = "| Challenge |"
    separator = "|-----------|"
    for m in models:
        header += f" {m['name']} |"
        separator += "--------|"
    lines.append(header)
    lines.append(separator)

    for ch in all_challenges:
        row = f"| {ch} |"
        for m in models:
            t = model_times.get(m["name"], {}).get(ch, 0)
            row += f" {t} |"
        lines.append(row)

    lines.append("")

    # Cost comparison
    lines.append("## Cost Comparison (USD)")
    lines.append("")
    header = "| Challenge |"
    separator = "|-----------|"
    for m in models:
        header += f" {m['name']} |"
        separator += "--------|"
    lines.append(header)
    lines.append(separator)

    for ch in all_challenges:
        row = f"| {ch} |"
        for m in models:
            c = model_costs.get(m["name"], {}).get(ch, 0)
            row += f" ${c:.4f} |"
        lines.append(row)

    lines.append("")

    # Overall statistics
    lines.append("## Overall Statistics")
    lines.append("")
    lines.append("| Model | Avg Score | Total Time | Total Cost | Challenges |")
    lines.append("|-------|-----------|------------|------------|------------|")

    for m in models:
        avg_s = sum(
            model_scores.get(m["name"], {}).get(ch, {}).get("score", 0)
            for ch in all_challenges
        ) / max(len(all_challenges), 1)
        total_t = sum(model_times.get(m["name"], {}).get(ch, 0) for ch in all_challenges)
        total_c = sum(model_costs.get(m["name"], {}).get(ch, 0) for ch in all_challenges)
        n_ch = len(
            [ch for ch in all_challenges if ch in model_scores.get(m["name"], {})]
        )
        lines.append(
            f"| {m['name']} | {avg_s:.2f} "
            f"| {format_elapsed(total_t)} "
            f"| ${total_c:.4f} | {n_ch}/{len(all_challenges)} |"
        )

    lines.append("")

    # Detailed per-model reports
    lines.append("## Detailed Model Reports")
    lines.append("")
    for m in models:
        lines.append(f"### {m['name']}")
        lines.append("")
        lines.append(f"[Full report]({m['name']}/REPORT.md)")
        lines.append("")

    return "\n".join(lines)


def main():
    if len(sys.argv) < 2:
        print("Usage: generate_report.py <model_dir_or_resultados>")
        print("")
        print("Examples:")
        print("  ./scripts/generate_report.py resultados/gpt-4o")
        print("  ./scripts/generate_report.py resultados/  (comparison)")
        sys.exit(1)

    target = Path(sys.argv[1])

    if not target.exists():
        print(f"Error: {target} not found")
        sys.exit(1)

    # Check if this is a model directory (has subdirectories with metrics.json)
    # or the main resultados directory
    is_resultados_dir = False
    if target.name == "resultados" and target.is_dir():
        is_resultados_dir = True
    elif target.is_dir():
        # Check if there are subdirectories with metrics files
        subdirs = [d for d in target.iterdir() if d.is_dir()]
        has_metrics = any(
            (d / "metrics.json").exists()
            for d in subdirs
        )
        if not has_metrics and len(subdirs) > 0:
            # Could be resultados dir passed by another name
            subsub_metrics = any(
                (sub / "metrics.json").exists()
                for d in subdirs
                for sub in d.iterdir()
                if sub.is_dir()
            )
            if subsub_metrics:
                is_resultados_dir = True

    if is_resultados_dir:
        report = generate_comparison_report(target)
        output_file = target / "COMPARISON.md"
    else:
        model_name = target.name
        challenges = discover_challenges(target)
        model_info = {"name": model_name, "dir": target, "challenges": challenges}
        report = generate_single_model_report(model_info)
        output_file = target / "REPORT.md"

    output_file.write_text(report)
    print(f"Report generated: {output_file}")

    # Print a quick summary to stdout
    lines = report.split("\n")
    for line in lines:
        if line.startswith("## Summary") or line.startswith("## Per-Challenge"):
            break
    print(report[:2000])  # Print first portion


if __name__ == "__main__":
    main()
