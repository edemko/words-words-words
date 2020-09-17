#!/usr/bin/env sh
set -e

dir="$1"
name="$2"
# ext="$3"

echo >&3 "FEEDS"

zedo phony

zedo if-change articles.txt
zedo if-change scripts/mk_feed.py


# FIXME have zedo make directories and clean them up
FEED_DIR="$name.d"
mkdir -p "$FEED_DIR"
trap 'rm -r "$FEED_DIR"' EXIT

cat articles.txt | \
while IFS= read articleName || [ -n "$articleName" ]; do
    zedo if-change "articles/$articleName.html"
    echo "articles/$articleName.html"
done | python3 scripts/mk_feed.py "$FEED_DIR" 2>"$ZEDO__ROOT/.zedo/log/mk_feed.stderr" # FIXME why is this not going to the right place automatically?

# FIXME register with zedo that additional files were created
mv "$FEED_DIR/atom.xml" "$FEED_DIR/rss.xml" "$dir/" # FIXME atom feed isn't generating right
