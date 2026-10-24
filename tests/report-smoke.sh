#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)"
REPORT="$ROOT/scripts/report"

allocate_name() {
    local directory
    directory="$(mktemp -d "$ROOT/projects/report-smoke.XXXXXXXX")"
    rmdir -- "$directory"
    basename -- "$directory"
}

printf '[START] LaTeX multi-project smoke test\n'
FIRST="$(allocate_name)"
SECOND="$(allocate_name)"
trap 'rm -rf -- "$ROOT/projects/$FIRST" "$ROOT/projects/$SECOND"' EXIT

printf '[1/5] Project creation RUNNING\n'
"$REPORT" new "$FIRST" >/dev/null
"$REPORT" new "$SECOND" >/dev/null
test -f "$ROOT/projects/$FIRST/main.tex"
test -f "$ROOT/projects/$SECOND/main.tex"
if "$REPORT" new "$FIRST" >/dev/null 2>&1; then
    printf '[RESULT] FAIL existing project overwritten\n'
    exit 1
fi
if "$REPORT" new '../escape' >/dev/null 2>&1; then
    printf '[RESULT] FAIL unsafe project name accepted\n'
    exit 1
fi
if "$REPORT" clean example/diabetes_report >/dev/null 2>&1; then
    printf '[RESULT] FAIL tracked example outputs were not protected\n'
    exit 1
fi
test "$("$REPORT" list | grep -xc "$FIRST")" -eq 1
test "$("$REPORT" list | grep -xc "$SECOND")" -eq 1
printf '[1/5] Project creation OK\n'

printf '[2/5] First PDF RUNNING\n'
if ! "$REPORT" build "$FIRST" >"$ROOT/projects/$FIRST/build-test.log" 2>&1; then
    tail -n 24 "$ROOT/projects/$FIRST/build-test.log"
    printf '[RESULT] FAIL first build\n'
    exit 1
fi
test -s "$ROOT/projects/$FIRST/main.pdf"
cmp "$ROOT/projects/$FIRST/main.pdf" "$ROOT/projects/$FIRST/build/main.pdf"
printf '[2/5] First PDF OK\n'

printf '[3/5] Second PDF RUNNING\n'
printf '\nIndependent second project.\n' >> "$ROOT/projects/$SECOND/sections/content.tex"
if ! "$REPORT" build "$SECOND" >"$ROOT/projects/$SECOND/build-test.log" 2>&1; then
    tail -n 24 "$ROOT/projects/$SECOND/build-test.log"
    printf '[RESULT] FAIL second build\n'
    exit 1
fi
test -s "$ROOT/projects/$SECOND/main.pdf"
cmp "$ROOT/projects/$SECOND/main.pdf" "$ROOT/projects/$SECOND/build/main.pdf"
first_hash="$(sha256sum "$ROOT/projects/$FIRST/main.pdf" | cut -d' ' -f1)"
second_hash="$(sha256sum "$ROOT/projects/$SECOND/main.pdf" | cut -d' ' -f1)"
test "$first_hash" != "$second_hash"
printf '[3/5] Second PDF OK\n'

printf '[4/5] Clean isolation RUNNING\n'
"$REPORT" clean "$FIRST" >/dev/null
test ! -e "$ROOT/projects/$FIRST/build"
test ! -e "$ROOT/projects/$FIRST/main.pdf"
test -f "$ROOT/projects/$FIRST/main.tex"
test -s "$ROOT/projects/$SECOND/main.pdf"
test "$(sha256sum "$ROOT/projects/$SECOND/main.pdf" | cut -d' ' -f1)" = "$second_hash"
printf '[4/5] Clean isolation OK\n'

printf '[5/5] Final cleanup RUNNING\n'
"$REPORT" clean "$SECOND" >/dev/null
test ! -e "$ROOT/projects/$SECOND/build"
test ! -e "$ROOT/projects/$SECOND/main.pdf"
printf '[5/5] Final cleanup OK\n'
printf '[RESULT] OK creation_build_isolation_cleanup\n'
