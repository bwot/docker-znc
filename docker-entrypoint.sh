#!/bin/sh
set -e

if [ "$1" = "znc" ]; then

  if [ ! -f "$ZNCDATA"/configs/znc.conf ]; then
    mkdir -p "$ZNCDATA"/configs && cp /znc.conf.default "$ZNCDATA"/configs/znc.conf
  fi

	chown -R znc "$ZNCDATA"

  exec su-exec znc "$@" --foreground --datadir="$ZNCDATA"
fi

exec "$@"
