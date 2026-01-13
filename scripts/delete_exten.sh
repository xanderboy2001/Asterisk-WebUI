#!/usr/bin/env bash
set -euo pipefail

__dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd )"
__file="${__dir}/$(basename "${BASH_SOURCE[0]}")"
__base="$(basename "${__file}" .sh)"

# --- HELP ---
# Deletes a specified extension from Asterisk's extensions.conf.
#
# Inputs / Expectations:
# - Prompts interactively for an extension number.
# - Uses /etc/asterisk/extensions.conf.
# - Requires write access to extensions.conf and /etc/asterisk/backup.
#
# Behavior:
# - Backs up extensions.conf to /etc/asterisk/backup before changes.
# - Deletes lines containing 'exten => <extension>'.
# - Removes any resulting blank lines.
# - Optionally reloads Asterisk if uncommented.
# ------------

source ${__dir}/input_validation.sh
check_nro_args --expected "1" --actual "$#"
validate_extension $1
extension="$1"

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

# Check if the extension exists in extensions.conf
if grep -q "exten => $extension" $EXTENSIONS_CONF; then
    echo "Found extension $extension in $EXTENSIONS_CONF. Deleting..."

    # Remove the extension lines from extensions.conf
    sed -i "/exten => $extension,/d" $EXTENSIONS_CONF

    # Remove any blank lines that might be left behind
    sed -i '/^$/d' $EXTENSIONS_CONF
    
    echo "Extension $extension has been deleted from $EXTENSIONS_CONF."
else
    echo "Extension $extension not found in $EXTENSIONS_CONF."
fi

# Reload Asterisk configuration (optional, uncomment if necessary)
# asterisk -rx "reload"

echo "Operation completed. Please review changes in $EXTENSIONS_CONF."

