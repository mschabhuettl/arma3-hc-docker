#!/bin/bash
set -e
set -x

# Check if Steam user credentials are provided
if [ -z "$STEAM_USER" ]; then
  >&2 echo "Error: STEAM_USER is not set."
  exit 1
fi

if [ -z "$STEAM_PASS" ]; then
  >&2 echo "Error: STEAM_PASS is not set."
  exit 1
fi

# Set default port if ARMA_PORT is not specified
if [ -z "$ARMA_PORT" ]; then
  ARMA_PORT=2302
  echo "Info: ARMA_PORT not set. Using default port 2302."
fi

# Ensure steamcmd is accessible
STEAMCMD_PATH="/usr/games/steamcmd"
if [ ! -x "$STEAMCMD_PATH" ]; then
  >&2 echo "Error: steamcmd not found at $STEAMCMD_PATH. Verify installation."
  exit 1
fi

# Run steamcmd to install or update Arma 3
$STEAMCMD_PATH \
    +login $STEAM_USER $STEAM_PASS \
    +runscript "$(realpath install_arma3.txt)"

# Ensure MPMissionsCache directory exists to avoid crashes
MP_MISSIONS_CACHE="/root/.local/share/Arma 3/MPMissionsCache"
mkdir -p "$MP_MISSIONS_CACHE"

# Navigate to Arma 3 installation directory
cd /arma3

# Launch Arma 3 headless client
./arma3server \
  -client \
  -connect=$ARMA_HOST \
  -port=$ARMA_PORT \
  -password="$ARMA_PASS" \
  -noSound \
  "$@"
