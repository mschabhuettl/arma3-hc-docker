#!/bin/bash
set -e

export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# Generate a random ID for this instance
RANDOM_ID=$(uuidgen | cut -c1-8)
echo "Generated Random ID: $RANDOM_ID"

# Ensure necessary directories exist
mkdir -p /arma3 /root/.local/share/Arma\ 3/MPMissionsCache

# Validate Steam user credentials
if [ -z "$STEAM_USER" ] || [ -z "$STEAM_PASS" ]; then
  >&2 echo "Error: STEAM_USER or STEAM_PASS is not set."
  exit 1
fi

# Default values for Arma 3 server connection
ARMA_PORT=${ARMA_PORT:-2302}
ARMA_HOST=${ARMA_HOST:-"127.0.0.1"}
ARMA_PASS=${ARMA_PASS:-""}

# Verify steamcmd availability
STEAMCMD_PATH="/usr/games/steamcmd"
if [ ! -x "$STEAMCMD_PATH" ]; then
  >&2 echo "Error: steamcmd not found at $STEAMCMD_PATH. Verify installation."
  exit 1
fi

# Verify existence of install_arma3.txt
INSTALL_SCRIPT=$(realpath install_arma3.txt)
if [ ! -f "$INSTALL_SCRIPT" ]; then
  >&2 echo "Error: install_arma3.txt not found."
  exit 1
fi

# Install or update Arma 3 files
echo "Running SteamCMD to update Arma 3 files..."
$STEAMCMD_PATH +login $STEAM_USER $STEAM_PASS +runscript "$INSTALL_SCRIPT"

if [ $? -eq 0 ]; then
  echo "Arma 3 Dedicated Server installation/update completed successfully."
else
  echo "Error: Arma 3 Dedicated Server installation/update failed." >&2
  exit 1
fi

# Variables for logs and identification
HEADLESS_CLIENT_NAME="headlessclient-$RANDOM_ID"
LOG_FILE="/arma3/headlessclient-$RANDOM_ID.log"

# Infinite retry loop for the headless client
while true; do
  echo "Starting Arma 3 headless client with ID: $RANDOM_ID..."

  if [ ! -x "/arma3/arma3server" ]; then
    >&2 echo "Error: arma3server not found or not executable in /arma3."
    exit 1
  fi

  /arma3/arma3server \
    -client \
    -connect=$ARMA_HOST \
    -port=$ARMA_PORT \
    -password="$ARMA_PASS" \
    -noSound \
    >> "$LOG_FILE" 2>&1 &

  CLIENT_PID=$!
  echo "Headless client started with PID: $CLIENT_PID and ID: $RANDOM_ID"

  # Monitor log file for specific client errors
  tail -n 0 -f "$LOG_FILE" | while read line; do
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
