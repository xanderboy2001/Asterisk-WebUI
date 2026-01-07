#!/usr/bin/env bash
set -euo pipefail

# --- HELP ---
# This script redirects one extension to another.
# ------------

source ./input_validation.sh

if [[ "${TESTING:-0}" == "1" ]]; then
	echo "[TEST MODE]"
	echo "Script: $0"
	echo "Arguments: $*"
	exit 0
fi

# Define the path to the extensions.conf file
EXTENSIONS_CONF="/etc/asterisk/extensions.conf"
BACKUP_DIR="/etc/asterisk/backup"

# Check if backup directory exists; if not, create it
if [ ! -d "$BACKUP_DIR" ]; then
    mkdir -p "$BACKUP_DIR"
fi

# Backup the extensions.conf file before modifying it
cp $EXTENSIONS_CONF $BACKUP_DIR/extensions.conf.bak_$(date +%F_%T)

# Ask the user for the source and destination extensions
read -p "Enter the source extension you want to redirect: " src_extension
read -p "Enter the destination extension (Local channel) to redirect to: " dest_extension

# Check if the source extension exists in extensions.conf
if grep -q "exten => $src_extension" $EXTENSIONS_CONF; then
    echo "Found source extension $src_extension in $EXTENSIONS_CONF, redirecting it to Local/$dest_extension@default."
    
    # Comment out the original lines related to the source extension
    sed -i "/exten => $src_extension/s/^/;/" $EXTENSIONS_CONF

    # Add a new line to redirect to the destination extension's Local channel
    echo "exten => $src_extension,1,Dial(Local/$dest_extension@default)" >> $EXTENSIONS_CONF
    
    echo "Extension $src_extension is now redirected to Local/$dest_extension@default in $EXTENSIONS_CONF."
else
    echo "Source extension $src_extension not found in $EXTENSIONS_CONF."
fi

# Reload Asterisk configuration (optional, uncomment if necessary)
# asterisk -rx "reload"

echo "Operation completed. Please review the changes in $EXTENSIONS_CONF."

