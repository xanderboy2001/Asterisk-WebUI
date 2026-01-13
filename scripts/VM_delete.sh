#!/usr/bin/env bash
set -euo pipefail

__dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd )"
__file="${__dir}/$(basename "${BASH_SOURCE[0]}")"
__base="$(basename "${__file}" .sh)"

# --- HELP ---# This script deletes a voicemail configuration for a specified extension from Asterisk's voicemail.conf.## Inputs / Behavior:# - Prompts the user for the extension whose voicemail box should be deleted.# - Backs up /etc/asterisk/voicemail.conf before making changes.# - Searches for the specified extension in voicemail.conf and deletes it if found.# - Prints a message if the extension is not found.# - Reloads Asterisk voicemail configuration if desired (command commented out by default).# ------------

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
read -p "Enter the extension number whose voicemail box you want to delete: " extension

# Check if the extension exists in voicemail.conf
if grep -q "^$extension\s*=" $VOICEMAIL_CONF; then
    echo "Voicemail box for extension $extension found. Deleting..."

    # Remove the voicemail entry for the extension
    sed -i "/^$extension\s*=/d" $VOICEMAIL_CONF

    echo "Voicemail box for extension $extension has been deleted from $VOICEMAIL_CONF."
else
    echo "Error: Voicemail box for extension $extension not found in $VOICEMAIL_CONF."
fi

# Reload Asterisk configuration (optional, uncomment if necessary)
# asterisk -rx "voicemail reload"

echo "Operation completed."

