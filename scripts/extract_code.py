#!/usr/bin/env python3
"""
Extract code blocks from model responses.

Reads a response.json file, extracts all fenced code blocks (```...```)
and any code-like content outside fences, then writes each extracted
file to the output directory.

Usage:
    ./scripts/extract_code.py <response.json> <output_dir>
"""

import json
import os
import re
import sys
from pathlib import Path


def extract_fenced_blocks(content):
    """Extract all fenced code blocks with their language annotations."""
    pattern = re.compile(
        r"```(?P<lang>\w*)\s*\n(?P<code>.*?)```",
        re.DOTALL,
    )
    blocks = []
    for match in pattern.finditer(content):
        lang = match.group("lang") or ""
        code = match.group("code")
        # Remove trailing whitespace
        code = code.rstrip()
        blocks.append({"language": lang, "code": code})
    return blocks


def infer_filename(language, code, hint_dir, known_files):
    """Infer the filename for a code block based on language and content hints."""
    ext_map = {
        "python": ".py",
        "py": ".py",
        "javascript": ".js",
        "js": ".js",
        "typescript": ".ts",
        "ts": ".ts",
        "jsx": ".jsx",
        "tsx": ".tsx",
        "html": ".html",
        "css": ".css",
        "go": ".go",
        "rust": ".rs",
        "rs": ".rs",
        "java": ".java",
        "kotlin": ".kt",
        "kt": ".kt",
        "dart": ".dart",
        "sql": ".sql",
        "bash": ".sh",
        "sh": ".sh",
        "shell": ".sh",
        "yaml": ".yaml",
        "yml": ".yml",
        "json": ".json",
        "xml": ".xml",
        "dockerfile": ".Dockerfile",
        "terraform": ".tf",
        "tf": ".tf",
        "hcl": ".tf",
        "jenkinsfile": "Jenkinsfile",
        "groovy": ".groovy",
        "ruby": ".rb",
        "rb": ".rb",
        "php": ".php",
        "c": ".c",
        "cpp": ".cpp",
        "h": ".h",
        "hpp": ".hpp",
        "swift": ".swift",
        "scala": ".scala",
        "r": ".r",
        "perl": ".pl",
        "lua": ".lua",
        "abap": ".abap",
        "cds": ".cds",
    }

    # Check for a shebang line
    first_line = code.strip().split("\n")[0] if code.strip() else ""
    shebang_map = {
        "#!/usr/bin/env python3": ".py",
        "#!/usr/bin/python3": ".py",
        "#!/usr/bin/python": ".py",
        "#!/bin/bash": ".sh",
        "#!/bin/sh": ".sh",
        "#!/usr/bin/env bash": ".sh",
        "#!/usr/bin/env node": ".js",
        "#!/usr/bin/env ruby": ".rb",
    }
    if first_line in shebang_map:
        ext = shebang_map[first_line]
        return f"script{ext}"

    if language.lower() in ext_map:
        ext = ext_map[language.lower()]
        if ext == "Jenkinsfile":
            return "Jenkinsfile"
        if language.lower() == "dockerfile":
            return "Dockerfile"
        return f"file{ext}"

    # Try to find a filename in the code itself (first line comment)
    comment_patterns = [
        re.compile(r"^#\s*(\S+\.\w+)"),  # Python/Ruby/shell comments
        re.compile(r"^//\s*(\S+\.\w+)"),  # JS/Go/C comments
        re.compile(r"^/\*\s*(\S+\.\w+)"),  # Block comment start
        re.compile(r"^--\s*(\S+\.\w+)"),  # SQL comments
        re.compile(r"^%\s*(\S+\.\w+)"),  # LaTeX/Matlab
    ]
    for pattern in comment_patterns:
        m = pattern.match(first_line)
        if m:
            return m.group(1)

    return None


def is_code_line(line):
    """Heuristic: check if a line looks like code."""
    stripped = line.strip()
    if not stripped:
        return False
    code_indicators = [
        "import ", "from ", "def ", "class ", "const ", "let ", "var ",
        "function", "return ", "if ", "else:", "elif ", "for ", "while ",
        "try:", "except:", "with ", "async ", "await ", "public ",
        "private ", "protected ", "static ", "void ", "int ", "float ",
        "string ", "bool ", "SELECT ", "FROM ", "WHERE ", "INSERT ",
        "CREATE ", "ALTER ", "DROP ", "UPDATE ", "DELETE ", "resource ",
        "data ", "provider ", "terraform", "apiVersion", "kind:",
        "metadata:", "spec:", "  ", "\t",
    ]
    return any(stripped.startswith(ind) for ind in code_indicators)


def extract_inline_code(content):
    """Extract code-like blocks that aren't in fenced blocks."""
    lines = content.split("\n")
    code_lines = []
    in_code = False
    blocks = []

    for line in lines:
        if is_code_line(line):
            if not in_code:
                in_code = True
                code_lines = []
            code_lines.append(line)
        else:
            if in_code and len(code_lines) >= 3:
                blocks.append({
                    "language": "",
                    "code": "\n".join(code_lines),
                })
            in_code = False
            code_lines = []

    if in_code and len(code_lines) >= 3:
        blocks.append({
            "language": "",
            "code": "\n".join(code_lines),
        })

    return blocks


def main():
    if len(sys.argv) < 2:
        print("Usage: extract_code.py <response.json> [output_dir]")
        sys.exit(1)

    response_path = Path(sys.argv[1])
    if not response_path.exists():
        print(f"Error: {response_path} not found")
        sys.exit(1)

    output_dir = Path(sys.argv[2]) if len(sys.argv) > 2 else response_path.parent / "solution"
    output_dir.mkdir(parents=True, exist_ok=True)

    with open(response_path) as f:
        response = json.load(f)

    # Get the content from various possible response formats
    content = ""
    if isinstance(response, dict):
        # OpenAI format
        if "choices" in response and len(response["choices"]) > 0:
            choice = response["choices"][0]
            if "message" in choice and "content" in choice["message"]:
                content = choice["message"]["content"]
            elif "text" in choice:
                content = choice["text"]
        # Anthropic format
        elif "content" in response:
            if isinstance(response["content"], list):
                for block in response["content"]:
                    if isinstance(block, dict) and block.get("type") == "text":
                        content += block.get("text", "")
                    elif isinstance(block, dict) and block.get("type") == "code":
                        content += f"```\n{block.get('text', '')}\n```\n"
            elif isinstance(response["content"], str):
                content = response["content"]
        # Google format
        elif "candidates" in response:
            candidates = response["candidates"]
            if candidates and len(candidates) > 0:
                candidate = candidates[0]
                if "content" in candidate and "parts" in candidate["content"]:
                    for part in candidate["content"]["parts"]:
                        if "text" in part:
                            content += part["text"]
        # Generic fallback
        elif "response" in response:
            content = str(response["response"])
    elif isinstance(response, str):
        content = response

    if not content:
        print(json.dumps({"error": "No content found in response", "files": []}, indent=2))
        return

    # Extract fenced code blocks
    blocks = extract_fenced_blocks(content)

    # If no fenced blocks, try inline extraction
    if not blocks:
        blocks = extract_inline_code(content)

    # Write each block to a file
    created_files = []
    used_names = set()

    for i, block in enumerate(blocks):
        fname = infer_filename(block["language"], block["code"], output_dir, list(used_names))
        if fname is None:
            fname = f"file_{i:03d}{'.py' if block['language'] in ('python', 'py', '') else '.txt'}"
        # Avoid name collisions
        base, ext = os.path.splitext(fname)
        counter = 1
        while fname in used_names:
            fname = f"{base}_{counter:03d}{ext}"
            counter += 1
        used_names.add(fname)

        filepath = output_dir / fname
        filepath.parent.mkdir(parents=True, exist_ok=True)
        filepath.write_text(block["code"])

        created_files.append({
            "filename": fname,
            "language": block["language"],
            "size_bytes": len(block["code"]),
            "path": str(filepath),
        })

    result = {
        "files": created_files,
        "total_files": len(created_files),
        "total_bytes": sum(f["size_bytes"] for f in created_files),
    }

    print(json.dumps(result, indent=2))


if __name__ == "__main__":
    main()
