#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)"
IMAGE="texlive/texlive:latest"
[[ "$#" -eq 1 && "$1" =~ ^[A-Za-z0-9][A-Za-z0-9._-]*$ ]] || { printf 'Usage: %s <name>\n' "$0" >&2; exit 1; }
PROJECT="$ROOT/projects/$1"
[[ -d "$PROJECT" && ! -L "$PROJECT" && -f "$PROJECT/main.tex" && ! -L "$PROJECT/main.tex" ]] || { printf 'Project not found: %s\n' "$1" >&2; exit 1; }
[[ ! -L "$PROJECT/build" && ! -L "$PROJECT/main.pdf" ]] || { printf 'Symlinked output is not allowed: %s\n' "$1" >&2; exit 1; }
command -v docker >/dev/null 2>&1 || { printf 'Docker is required. Run ./scripts/setup.sh first.\n' >&2; exit 1; }
mkdir -p -- "$PROJECT/build"
docker run --rm --user "$(id -u):$(id -g)" \
    --mount "type=bind,source=$PROJECT,target=/work" --workdir /work \
    --env HOME=/tmp "$IMAGE" \
    latexmk -xelatex -interaction=nonstopmode -halt-on-error -file-line-error -synctex=1 -outdir=build main.tex
cp -- "$PROJECT/build/main.pdf" "$PROJECT/main.pdf"
printf 'PDF: %s\n' "$PROJECT/main.pdf"
