#!/usr/bin/env sh
set -e

zedo phony

for md in src/articles/*.md; do
    target=${md#src/}
    zedo ifchange "$target"
done
zedo ifchange index.html archive.html about.html feeds
