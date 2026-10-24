#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)"
[[ "$#" -ge 1 && "$#" -le 2 && "$1" =~ ^[A-Za-z0-9][A-Za-z0-9._-]*$ ]] || { printf 'Usage: %s <name> [example-lite|example-full]\n' "$0" >&2; exit 1; }
TEMPLATE="${2:-example-lite}"
[[ "$TEMPLATE" == example-lite || "$TEMPLATE" == example-full ]] || { printf 'Unknown template: %s\n' "$TEMPLATE" >&2; exit 1; }
PROJECT="$ROOT/projects/$1"
[[ ! -e "$PROJECT" && ! -L "$PROJECT" ]] || { printf 'Project already exists: %s\n' "$1" >&2; exit 1; }
mkdir -- "$PROJECT"
tar -C "$ROOT/projects/$TEMPLATE" --exclude='./build' --exclude='./main.pdf' -cf - . | tar -C "$PROJECT" -xf -
printf 'Created: %s (from %s)\n' "$PROJECT" "$TEMPLATE"
