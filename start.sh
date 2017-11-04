#!/bin/bash
set -e
set -x

if [ -z "$STEAM_USER" ]; then
  >&2 echo "STEAM_USER is not set"
  exit 1
fi

if [ -z "$STEAM_PASS" ]; then
  >&2 echo "STEAM_PASS is not set"
  exit 1
fi

if [ -z "$ARMA_PORT" ]; then
  ARMA_PORT=2302
fi

/usr/games/steamcmd \
    +login $STEAM_USER $STEAM_PASS \
    +runscript `realpath install_arma3.txt` \

cd /arma3
./arma3server \
  -client \
  -connect=$ARMA_HOST \
  -port=$ARMA_PORT \
  -password="$ARMA_PASS" \
  -noSound \
