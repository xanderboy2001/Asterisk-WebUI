#!/usr/bin/env bash
set -euo pipefail

# --- HELP ---
# Deletes a voicemail box from Asterisk's voicemail.conf.
#
# Inputs / Expectations:
# - Prompts interactively for an extension number.
# - Uses /etc/asterisk/voicemail.conf.
# - Requires write access to voicemail.conf and /etc/asterisk/backup.
#
# Behavior:
# - Backs up voicemail.conf before making changes.
# - Removes the line defining the specified extension.
# - Cleans up any blank lines left behind.
# - Optionally reloads Asterisk if uncommented.
# ------------

source ./input_validation.sh
check_nro_args --expected "1" --actual "$#"
validate_extension "$1"
extension="$1"

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

# Backup the voicemail.conf file before modifying it
cp $VOICEMAIL_CONF $BACKUP_DIR/voicemail.conf.bak_$(date +%F_%T)

# Check if the voicemail box exists for the given extension
if grep -q "^$extension =>" $VOICEMAIL_CONF; then
    echo "Found voicemail box for extension $extension in $VOICEMAIL_CONF. Deleting..."
    
    # Remove the voicemail box configuration from voicemail.conf
    sed -i "/^$extension =>/d" $VOICEMAIL_CONF

    # Remove any blank lines left behind
    sed -i '/^$/d' $VOICEMAIL_CONF

    echo "Voicemail box for extension $extension has been deleted from $VOICEMAIL_CONF."
else
    echo "Voicemail box for extension $extension not found in $VOICEMAIL_CONF."
fi

# Reload Asterisk configuration (optional, uncomment if necessary)
# asterisk -rx "reload"

echo "Operation completed. Please review changes in $VOICEMAIL_CONF."

