#!/usr/bin/env bash
set -euo pipefail

__dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd )"
__file="${__dir}/$(basename "${BASH_SOURCE[0]}")"
__base="$(basename "${__file}" .sh)"

# --- HELP ---
# This script resets the voicemail PIN for a specified extension.
#
# Inputs / Behavior:
# - Prompts for the extension whose voicemail PIN needs to be reset.
# - Prompts for a new PIN (must be numeric and at least 4 digits).
# - Creates a backup of /etc/asterisk/voicemail.conf before changes.
# - Updates only the PIN field for the specified extension.
# - Reloads Asterisk voicemail configuration.
# ------------

source ./input_validation.sh

if [[ "${TESTING:-0}" == "1" ]]; then
	echo "[TEST MODE]"
	echo "Script: $0"
	echo "Arguments: $*"
	exit 0
fi

# Define the path to voicemail.conf
VOICEMAIL_CONF="/etc/asterisk/voicemail.conf"
BACKUP_DIR="/etc/asterisk/backup"

# Check if backup directory exists; if not, create it
if [ ! -d "$BACKUP_DIR" ]; then
    mkdir -p "$BACKUP_DIR"
fi

# Backup voicemail.conf before modifying it
cp $VOICEMAIL_CONF $BACKUP_DIR/voicemail.conf.bak_$(date +%F_%T)

# Prompt the user for the extension
read -p "Enter the extension for which you want to reset the voicemail PIN: " extension

# Check if the extension exists in voicemail.conf
if grep -q "^$extension\s*=" $VOICEMAIL_CONF; then
    echo "Voicemail box for extension $extension found."
    
    # Prompt for the new PIN
    read -p "Enter the new voicemail PIN: " new_pin

    # Validate the new PIN (must be numeric and at least 4 digits)
    if [[ ! $new_pin =~ ^[0-9]{4,}$ ]]; then
        echo "Error: The PIN must be numeric and at least 4 digits."
        exit 1
    fi

    # Update the PIN for the extension in voicemail.conf while keeping other fields intact
    sed -i "s/^\($extension\s*=\s*\)[^,]*/\1$new_pin/" $VOICEMAIL_CONF

    echo "The voicemail PIN for extension $extension has been updated."
else
    echo "Error: Voicemail box for extension $extension not found in $VOICEMAIL_CONF."
fi

# Reload Asterisk configuration (optional, uncomment if necessary)
 asterisk -rx "voicemail reload"

echo "Operation completed."

