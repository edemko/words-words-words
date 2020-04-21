#!/bin/bash
set -e
shopt -s globstar

zedo phony

# zedo ifchange all

if which 2>/dev/null mini_httpd; then
    HTTPD=mini_httpd
elif which 2>/dev/null mini-httpd; then
    HTTPD=mini-httpd
else
    echo >&3 "no known httpd"
fi

_term() {
  echo "Caught SIGTERM signal!"
  kill "$child" 2>/dev/null
  exit 0
}
trap _term TERM INT HUP QUIT EXIT KILL

port=10080
echo >&3 "Starting server on port $port..."
echo >&3 "(Ctrl-C to exit)"
"$HTTPD" -D -u "$USER" -p "$port" -d "$ZEDO__ROOT/$BUILD/" 1>&3 2>&3 &
child=$!

wait "$child"
