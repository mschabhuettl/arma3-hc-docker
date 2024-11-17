#!/bin/bash
set -e

export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# Generate a random ID for this instance
RANDOM_ID=$(uuidgen | cut -c1-8)
echo "Generated Random ID: $RANDOM_ID"

# Ensure necessary directories exist
mkdir -p /arma3 /root/.local/share/Arma\ 3/MPMissionsCache

# Check if Steam user credentials are provided
if [ -z "$STEAM_USER" ] || [ -z "$STEAM_PASS" ]; then
  >&2 echo "Error: STEAM_USER or STEAM_PASS is not set."
  exit 1
fi

# Set default port if ARMA_PORT is not specified
ARMA_PORT=${ARMA_PORT:-2302}

# Ensure steamcmd is accessible
STEAMCMD_PATH="/usr/games/steamcmd"
if [ ! -x "$STEAMCMD_PATH" ]; then
  >&2 echo "Error: steamcmd not found at $STEAMCMD_PATH. Verify installation."
  exit 1
fi

# Verify install_arma3.txt exists
INSTALL_SCRIPT=$(realpath install_arma3.txt)
if [ ! -f "$INSTALL_SCRIPT" ]; then
  >&2 echo "Error: install_arma3.txt not found."
  exit 1
fi

# Install or update Arma 3 via SteamCMD
$STEAMCMD_PATH +login $STEAM_USER $STEAM_PASS +runscript "$INSTALL_SCRIPT"

HEADLESS_CLIENT_NAME="headlessclient-$RANDOM_ID"
LOG_FILE="/arma3/headlessclient-$RANDOM_ID.log"

while true; do
  echo "Starting Arma 3 headless client with ID: $RANDOM_ID..."

  if [ ! -x "./arma3server" ]; then
    >&2 echo "Error: arma3server not found or not executable in $(pwd)."
    exit 1
  fi

  ./arma3server \
    -client \
    -connect=$ARMA_HOST \
    -port=$ARMA_PORT \
    -password="$ARMA_PASS" \
    -noSound \
    >> "/arma3/headlessclient-$RANDOM_ID.log" 2>&1 &

  CLIENT_PID=$!
  echo "Headless client started with PID: $CLIENT_PID and ID: $RANDOM_ID"

  # Monitor the specific log file
  tail -n 0 -f "/arma3/headlessclient-$RANDOM_ID.log" | while read line; do
    echo "$line"
    if [[ "$line" == *"kicked"* ]] || 
       [[ "$line" == *"authentication failed"* ]] || 
       [[ "$line" == *"Invalid ticket"* ]] || 
       [[ "$line" == *"not responding"* ]]; then
      echo "Detected issue for Headless Client $RANDOM_ID. Restarting..."
      kill -9 $CLIENT_PID
      break
    fi
  done

  echo "Client $RANDOM_ID stopped unexpectedly. Restarting in 10 seconds..."
  sleep 10
done
