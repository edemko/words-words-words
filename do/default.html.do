#!/usr/bin/env bash
set -e

SRC="$(zedo ifchange -f "${2}.md")"


MDC="$(zedo ifchange -f scripts/mdc.py)"
templDir="src/templates"
# FIXME these redos should be called from $MDC
zedo ifchange templates/base.html.mako
zedo ifchange templates/bare.html.mako

python3 "$MDC" "$templDir" "$SRC" "$1"
