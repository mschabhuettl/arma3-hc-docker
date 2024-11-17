#!/bin/bash
set -e

# Generate a random ID for this instance
RANDOM_ID=$(uuidgen | cut -c1-8) # Shorten the UUID to 8 characters for simplicity
echo "Generated Random ID: $RANDOM_ID"

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

# Install or update Arma 3 via SteamCMD
$STEAMCMD_PATH \
    +login $STEAM_USER $STEAM_PASS \
    +runscript "$INSTALL_SCRIPT"

# Ensure MPMissionsCache directory exists to avoid crashes
MP_MISSIONS_CACHE="/root/.local/share/Arma 3/MPMissionsCache"
mkdir -p "$MP_MISSIONS_CACHE"

# Define the client name for log filtering
HEADLESS_CLIENT_NAME="headlessclient-$RANDOM_ID"

# Retry mechanism for all errors and disconnections specific to the Headless Client
while true; do
  echo "Starting Arma 3 headless client with ID: $RANDOM_ID..."

  # Verify arma3server exists and is executable
  if [ ! -x "./arma3server" ]; then
    >&2 echo "Error: arma3server not found or not executable in $(pwd)."
    exit 1
  fi

  # Start the Arma 3 headless client in the background and log output
  ./arma3server \
    -client \
    -connect=$ARMA_HOST \
    -port=$ARMA_PORT \
    -password="$ARMA_PASS" \
    -name=$HEADLESS_CLIENT_NAME \
    -noSound \
    "$@" >> "/arma3/headlessclient-$RANDOM_ID.log" 2>&1 &

  CLIENT_PID=$!
  echo "Headless client started with PID: $CLIENT_PID and ID: $RANDOM_ID"

  # Monitor the log for issues related to the Headless Client
  tail -n 0 -f "/arma3/headlessclient-$RANDOM_ID.log" | grep --line-buffered "$HEADLESS_CLIENT_NAME" | while read line; do
    echo "$line"
    if [[ "$line" == *"kicked"* ]] || 
       [[ "$line" == *"authentication failed"* ]] || 
       [[ "$line" == *"connection timeout"* ]] || 
       [[ "$line" == *"Invalid ticket"* ]] || 
       [[ "$line" == *"disconnected"* ]] || 
       [[ "$line" == *"not responding"* ]]; then
      echo "Detected issue for $HEADLESS_CLIENT_NAME. Restarting..."
      kill -9 $CLIENT_PID
      break
    fi
  done

  echo "Client $HEADLESS_CLIENT_NAME stopped unexpectedly. Restarting in 10 seconds..."
  sleep 10
done
