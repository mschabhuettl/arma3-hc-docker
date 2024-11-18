#!/bin/bash
set -e

export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# Generate a random ID for this instance
RANDOM_ID=$(uuidgen | cut -c1-8)
HC_NAME="${HC_NAME_PREFIX}${RANDOM_ID}"
echo "Generated Random ID: $RANDOM_ID"

# Ensure necessary directories exist
mkdir -p /root/.local/share/Arma\ 3/MPMissionsCache

# Default values for Arma 3 server connection
ARMA_PORT=${ARMA_PORT:-2302}
ARMA_HOST=${ARMA_HOST:-"127.0.0.1"}
ARMA_PASS=${ARMA_PASS:-""}

# Variables for additional parameters
CPU_COUNT_PARAM=""
if [ -n "$HC_CPU_COUNT" ]; then
  CPU_COUNT_PARAM="-cpuCount=$HC_CPU_COUNT"
fi

EX_THREADS_PARAM=""
if [ -n "$HC_EX_THREADS" ]; then
  EX_THREADS_PARAM="-exThreads=$HC_EX_THREADS"
fi

# Additional launch parameters from environment
ADDITIONAL_PARAMS="$HC_ADDITIONAL_PARAMS"

# Variables for logs and identification
HEADLESS_CLIENT_NAME="$HC_NAME"
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
    $CPU_COUNT_PARAM \
    $EX_THREADS_PARAM \
    $ADDITIONAL_PARAMS \
    -name="$HC_NAME" \
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
