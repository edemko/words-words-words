#!/usr/bin/env sh
set -e

zedo phony

echo >&2 "src/articles/*.md"
for md in src/articles/*.md; do
    target=${md#src/}
    zedo ifchange "$target"
done

echo >&2 "index.html"
zedo ifchange index.html
echo >&2 "archive.html"
zedo ifchange archive.html
echo >&2 "about.html"
zedo ifchange about.html
echo >&2 "feeds"
zedo ifchange feeds
echo >&2 "working.html"
zedo ifchange working.html
