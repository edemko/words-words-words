#!/usr/bin/env sh
set -e

zedo phony

ARTICLES="$(zedo ifchange -f articles.txt)"


MK_FEED="$(zedo ifchange -f scripts/mk_feed.py)"

FEED_DIR="${1}.d"
mkdir "$FEED_DIR"
trap "rm -r '$FEED_DIR'" EXIT

while IFS="" read articleName || [ -n "$articleName" ]; do
    articleHtml="$(zedo ifchange -f "articles/${articleName}.html")"
    echo "$articleHtml"
done < "$ARTICLES" | python3 "$MK_FEED" "$FEED_DIR"

mv "$FEED_DIR/atom.xml" "$FEED_DIR/rss.xml" "$(dirname "$1")" # FIXME atom feed isn't generating right
