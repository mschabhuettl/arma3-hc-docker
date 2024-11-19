#!/bin/bash
set -e

export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# Set default prefix if not provided
HC_NAME_PREFIX=${HC_NAME_PREFIX:-"arma3_hc_"}

# Generate a unique random ID for this instance
while :; do
  RANDOM_ID=$(uuidgen | cut -c1-8)
  HC_NAME="${HC_NAME_PREFIX}${RANDOM_ID}"
  if [ ! -e "/logs/${HC_NAME}.log" ]; then
    break
  fi
  echo "Random ID $RANDOM_ID already exists, generating a new one..."
done
echo "Generated Random ID: $RANDOM_ID"

# Ensure necessary directories exist
mkdir -p /root/.local/share/Arma\ 3/MPMissionsCache
mkdir -p /logs

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

# Mod parameters if ARMA_MODS is defined
MOD_PARAM=""
if [ -n "$ARMA_MODS" ]; then
  MODS_WITH_AT=""
  IFS=';' read -ra MODS <<< "$ARMA_MODS"
  for mod in "${MODS[@]}"; do
    MODS_WITH_AT+="mods/@${mod};"
  done
  MOD_PARAM="-mod=${MODS_WITH_AT%;}"
fi

# Variables for logs and identification
LOG_FILE="/logs/${HC_NAME}.log"

# Infinite retry loop for the headless client
while true; do
  echo "Starting Arma 3 headless client with name: $HC_NAME, ID: $RANDOM_ID..."

  if [ ! -x "/arma3/arma3server" ]; then
    >&2 echo "Error: arma3server not found or not executable in /arma3."
    exit 1
  fi

  /arma3/arma3server \
    -client \
    -connect="$ARMA_HOST" \
    -port="$ARMA_PORT" \
    -password="$ARMA_PASS" \
    $CPU_COUNT_PARAM \
    $EX_THREADS_PARAM \
    $ADDITIONAL_PARAMS \
    $MOD_PARAM \
    -name="$HC_NAME" \
    >> "$LOG_FILE" 2>&1 &

  CLIENT_PID=$!
  echo "Headless client started with name: $HC_NAME, PID: $CLIENT_PID, and ID: $RANDOM_ID"

  # Monitor log file for specific client errors
  tail -n 0 -f "$LOG_FILE" | while read -r line; do
    echo "$line"
    if [[ "$line" == *"kicked"* ]] ||
       [[ "$line" == *"authentication failed"* ]] ||
       [[ "$line" == *"Invalid ticket"* ]] ||
       [[ "$line" == *"not responding"* ]]; then
      echo "Detected issue for Headless Client $HC_NAME (ID: $RANDOM_ID). Restarting..."
      kill -9 $CLIENT_PID
      break
    fi
  done

  echo "Client $HC_NAME (ID: $RANDOM_ID) stopped unexpectedly. Restarting in 10 seconds..."
  sleep 10
done
