#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)"
IMAGE="texlive/texlive:latest"
[[ "$#" -ge 1 && "$#" -le 2 && "$1" =~ ^[A-Za-z0-9][A-Za-z0-9._-]*$ ]] || { printf 'Usage: %s <name> [source.tex]\n' "$0" >&2; exit 1; }
SOURCE="main.tex"
if [[ "$#" -eq 2 ]]; then
    SOURCE="$2"
fi
[[ "$SOURCE" =~ ^[A-Za-z0-9][A-Za-z0-9._-]*\.tex$ ]] || { printf 'Invalid source: %s\n' "$SOURCE" >&2; exit 1; }
PROJECT="$ROOT/projects/$1"
[[ -d "$PROJECT" && ! -L "$PROJECT" && -f "$PROJECT/$SOURCE" && ! -L "$PROJECT/$SOURCE" ]] || { printf 'Project or source not found: %s/%s\n' "$1" "$SOURCE" >&2; exit 1; }
PDF="$(printf '%s' "$SOURCE" | sed 's/\.tex$/.pdf/')"
[[ ! -L "$PROJECT/build" && ! -L "$PROJECT/$PDF" ]] || { printf 'Symlinked output is not allowed: %s\n' "$PDF" >&2; exit 1; }
command -v docker >/dev/null 2>&1 || { printf 'Docker is required. Run ./scripts/setup.sh first.\n' >&2; exit 1; }
mkdir -p -- "$PROJECT/build"
docker run --rm --user "$(id -u):$(id -g)" \
    --mount "type=bind,source=$PROJECT,target=/work" --workdir /work \
    --env HOME=/tmp "$IMAGE" \
    latexmk -xelatex -interaction=nonstopmode -halt-on-error -file-line-error -synctex=1 -outdir=build "$SOURCE"
cp -- "$PROJECT/build/$PDF" "$PROJECT/$PDF"
printf 'PDF: %s\n' "$PROJECT/$PDF"
