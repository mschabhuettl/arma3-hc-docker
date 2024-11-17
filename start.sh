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

# Verify install_arma3.txt exists
INSTALL_SCRIPT=$(realpath install_arma3.txt)
if [ ! -f "$INSTALL_SCRIPT" ]; then
  >&2 echo "Error: install_arma3.txt not found at $(pwd)."
  exit 1
fi

# Logout to ensure no active Steam sessions interfere
$STEAMCMD_PATH +login anonymous +quit

# Retry Steam login if necessary
for i in {1..3}; do
    $STEAMCMD_PATH \
        +login $STEAM_USER $STEAM_PASS \
        +runscript "$INSTALL_SCRIPT" && break || {
        echo "Retrying Steam login... attempt $i of 3"
        sleep 10
    }
    if [ "$i" -eq 3 ]; then
        >&2 echo "Error: Failed to authenticate with Steam after 3 attempts."
        exit 1
    fi
done

# Ensure MPMissionsCache directory exists to avoid crashes
MP_MISSIONS_CACHE="/root/.local/share/Arma 3/MPMissionsCache"
mkdir -p "$MP_MISSIONS_CACHE"

# Navigate to Arma 3 installation directory
cd /arma3

# Retry mechanism for all errors
while true; do
  echo "Starting Arma 3 headless client..."

  # Verify arma3server exists and is executable
  if [ ! -x "./arma3server" ]; then
    >&2 echo "Error: arma3server not found or not executable in $(pwd)."
    exit 1
  fi

  # Launch Arma 3 headless client
  ./arma3server \
    -client \
    -connect=$ARMA_HOST \
    -port=$ARMA_PORT \
    -password="$ARMA_PASS" \
    -noSound \
    "$@"

  # Log the restart and retry
  echo "Arma 3 headless client exited unexpectedly. Retrying in 10 seconds..."
  sleep 10
done
