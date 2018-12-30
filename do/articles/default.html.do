#!/usr/bin/env bash
set -e

SRC="$(zedo ifchange -f "${2}.md")"


MDC="$(zedo ifchange -f scripts/mdc.py)"
templDir="src/templates"

python3 "$MDC" "$templDir" "$SRC" "$1" --article
mv "$1.meta" "$(zedo find "${2}.html").meta"
