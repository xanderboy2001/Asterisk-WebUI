#!/usr/bin/env bash
set -euo pipefail

__dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd )"
__file="${__dir}/$(basename "${BASH_SOURCE[0]}")"
__base="$(basename "${__file}" .sh)"

# --- HELP ---
# This script redirects one extension to another.
# ------------

source ./input_validation.sh

parsed=$(getopt -o '' -l "source-extension:,destination-extension:" -- "$@") \
		|| exit_error "${__file}: invalid arguments"

eval set -- "$parsed"

while true; do
		case "$1" in
				--source-extension)
						src_extension="$2"
						shift 2
						;;
				--destination-extension)
						dest_extension="$2"
						shift 2
						;;
				--)
						shift
						break
						;;
				*)
						exit_error "${__file}: unexpected argument '$1'"
						;;
		esac
done

[ -n "${src_extension:-}" ] \
		|| exit_error "${__file}: --source-extension is required"
[ -n "${dest_extension:-}" ] \
		|| exit_error "${__file}: --destination-extension is required"

validate_extension "${src_extension}"
validate_extension "${dest_extension}"

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

