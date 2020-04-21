#!/usr/bin/env sh
set -e

zedo phony

zedo ifchange feeds
# zedo ifchange archive.html
zedo ifchange working.html

echo >&3 "MISC"
zedo ifchange index.html
zedo ifchange about.html


echo >&3 "Accumulating assets and static files…"
for f in "$ZEDO__ROOT/$SRC/"{assets,static}/**/*; do
    if ! [ -f "$f" ]; then continue; fi
    f="${f#$ZEDO__ROOT/$SRC/}"
    zedo if-change "src:$f"
done
