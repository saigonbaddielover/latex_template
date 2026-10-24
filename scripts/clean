#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)"
[[ "$#" -eq 1 && "$1" =~ ^[A-Za-z0-9][A-Za-z0-9._-]*$ ]] || { printf 'Usage: %s <name>\n' "$0" >&2; exit 1; }
PROJECT="$ROOT/projects/$1"
[[ -d "$PROJECT" && ! -L "$PROJECT" && -f "$PROJECT/main.tex" && ! -L "$PROJECT/main.tex" ]] || { printf 'Project not found: %s\n' "$1" >&2; exit 1; }
[[ ! -L "$PROJECT/build" && ! -L "$PROJECT/main.pdf" ]] || { printf 'Symlinked output is not allowed: %s\n' "$1" >&2; exit 1; }
rm -rf -- "$PROJECT/build"
rm -f -- "$PROJECT/main.pdf"
printf 'Cleaned: %s\n' "$PROJECT"
