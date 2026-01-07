#!/usr/bin/env bash
set -euo pipefail

# --- HELP ---
# Checks whether a given extension is defined in Asterisk's dialplan.
#
# Inputs / Expectations:
# - Prompts interactively for an extension number.
# - Uses /etc/asterisk/extensions.conf.
# - Read access to the dialplan file is required.
#
# Behavior:
# - Exits with an error if extensions.conf is missing.
# - Searches for an exact 'exten =>' match for the provided extension.
# - Reports whether the extension is in use or free.
#
# Notes:
# - Does not account for includes, pattern matches (_X., _NXX), or generated dialplans.
# ------------

source ./input_validation.sh

if [[ "${TESTING:-0}" == "1" ]]; then
	echo "[TEST MODE]"
	echo "Script: $0"
	echo "Arguments: $*"
	exit 0
fi

# Define the path to extensions.conf
EXTENSIONS_CONF="/etc/asterisk/extensions.conf"

# Check if the file exists
if [ ! -f "$EXTENSIONS_CONF" ]; then
    echo "Error: $EXTENSIONS_CONF not found."
    exit 1
fi

# Ask the user for the extension to check
read -p "Enter the extension you want to check: " extension

# Check if the extension is present in the extensions.conf file
if grep -q "exten => $extension" $EXTENSIONS_CONF; then
    echo "Extension $extension is already in use."
else
    echo "Extension $extension is free."
fi

