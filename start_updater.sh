#!/bin/bash
set -e

export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# Validate Steam user credentials
if [ -z "$STEAM_USER" ] || [ -z "$STEAM_PASS" ]; then
  >&2 echo "Error: STEAM_USER or STEAM_PASS is not set."
  exit 1
fi

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
