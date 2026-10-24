#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)"
[[ "$#" -eq 0 ]] || { printf 'Usage: %s\n' "$0" >&2; exit 1; }
find "$ROOT/projects" -mindepth 1 -maxdepth 1 -type d -printf '%f\n' | LC_ALL=C sort
