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

# Load environment variables
if [ -f "arma3_hc_config.env" ]; then
  source arma3_hc_config.env
else
  >&2 echo "Error: arma3_hc_config.env not found."
  exit 1
fi

# Create a new arma3_update_script.txt script with mods
cat << EOF > arma3_update_script.txt
// Stop the script if any commands fail
@ShutdownOnFailedCommand 1

// Do not prompt for a password, use the one specified in the login command
@NoPromptForPassword 1

// Set the installation directory for Arma 3 Dedicated Server
force_install_dir /arma3

// Install or update the Arma 3 Dedicated Server files (App ID: 233780)
app_update 233780 validate

// Install or update Mods based on arma3_hc_config.env
EOF

# Add each mod from ARMA_MODS_ARRAY to the arma3_update_script.txt script
for mod in "${ARMA_MODS_ARRAY[@]}"; do
  echo "workshop_download_item 107410 $mod validate" >> arma3_update_script.txt
done

# Add exit command to SteamCMD script
echo "quit" >> arma3_update_script.txt

# Install or update Arma 3 files
echo "Running SteamCMD to update Arma 3 files..."
$STEAMCMD_PATH +login $STEAM_USER $STEAM_PASS +runscript arma3_update_script.txt

if [ $? -eq 0 ]; then
  echo "Arma 3 Dedicated Server installation/update completed successfully."
else
  echo "Error: Arma 3 Dedicated Server installation/update failed." >&2
  exit 1
fi
