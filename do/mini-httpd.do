#!/usr/bin/env sh
set -e

zedo phony


if [ ! -e .zedo/build/assets ]; then ln -s ../../src/assets .zedo/build/; fi
if [ ! -e .zedo/build/assets ]; then ln -s ../../src/static .zedo/build/; fi


# zedo ifchange all

if which mini_httpd >/dev/null; then
    HTTPD=mini_httpd
elif which mini-httpd >/dev/null; then
    HTTPD=mini-httpd
else
    echo >&2 "no known httpd"
fi

echo >&2 "Starting server..."
exec "$HTTPD" -D -u "$USER" -p 10080 -d .zedo/build/
