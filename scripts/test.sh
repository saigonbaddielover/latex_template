#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)"
[[ "$#" -eq 0 ]] || { printf 'Usage: %s\n' "$0" >&2; exit 1; }

for NAME in example-lite example-long; do
    PROJECT="$ROOT/projects/$NAME"
    PDF="$PROJECT/main.pdf"
    "$ROOT/scripts/clean.sh" "$NAME" >/dev/null
    mkdir -p -- "$PROJECT/build"
    LOG="$PROJECT/build/test.log"
    printf 'Building %s to verify LaTeX to PDF...\n' "$NAME"
    if ! "$ROOT/scripts/build.sh" "$NAME" >"$LOG" 2>&1; then
        tail -n 30 "$LOG" >&2
        printf 'Example build failed; see %s\n' "$LOG" >&2
        exit 1
    fi
    [[ -s "$PDF" && "$(head -c 5 "$PDF")" == '%PDF-' ]] || { printf 'Example PDF is missing or invalid: %s\n' "$PDF" >&2; exit 1; }
    cmp -s -- "$PDF" "$PROJECT/build/main.pdf" || { printf 'Example PDF differs from build output: %s\n' "$PDF" >&2; exit 1; }
    printf 'Example PDF verified: %s\n' "$PDF"
done
