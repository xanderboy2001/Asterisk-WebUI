#!/usr/bin/env bash
set -euo pipefail

__dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd )"
__file="${__dir}/$(basename "${BASH_SOURCE[0]}")"
__base="$(basename "${__file}" .sh)"

# --- HELP ---
# Creates a SEP configuration file for a Cisco 7965 IP phone.
#
# Inputs / Expectations:
# - Prompts interactively for an extension number.
# - Uses /etc/asterisk/extensions.conf and /var/lib/tftpboot template (SEP0000000.cnf.xml).
# - Requires read/write access to TFTP boot directory and extensions.conf.
# - Requires Asterisk CLI access to reload dialplan and SIP.
#
# Behavior:
# - Looks up the MAC address for the extension from extensions.conf.
# - Backs up any existing configuration file for the phone.
# - Copies the template and replaces placeholders with the extension and MAC.
# - Sets TFTP directory permissions and reloads dialplan and SIP configs.
# - Optionally reboots the phone using a Python script if available.
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

# Enable debugging and exit on error
set -ex

# Define paths
TFTPBOOT_PATH="/var/lib/tftpboot"
EXTENSIONS_CONF="/etc/asterisk/extensions.conf"
TEMPLATE_FILE="$TFTPBOOT_PATH/SEP0000000.cnf.xml"
BACKUP_DIR="$TFTPBOOT_PATH/configs"
REBOOT_SCRIPT="/var/lib/asterisk/scripts/reboot_phone.py"

# Create backup directory if it doesn't exist
mkdir -p "$BACKUP_DIR"

echo "This script will create the SEP file for a 7965 IP Phone"

# Look up the MAC address from extensions.conf, ignoring data after an &
macaddress=$(grep -E "exten\s*=>\s*$extension,1,Dial\(SIP/SEP[0-9A-Fa-f]+" "$EXTENSIONS_CONF" | sed -E 's/.*Dial\(SIP\/SEP([0-9A-Fa-f]+).*/\1/' | head -n 1)

if [ -z "$macaddress" ]; then
  echo "MAC address for extension $extension not found in $EXTENSIONS_CONF."
  exit 1
fi

echo -e "\nRetrieved MAC address: $macaddress for Extension: $extension"

# Check if a configuration file already exists for this MAC address
CONFIG_FILE="$TFTPBOOT_PATH/SEP${macaddress}.cnf.xml"
if [ -f "$CONFIG_FILE" ]; then
  echo -e "\nExisting configuration file found for MAC address $macaddress."

  # Backup the existing configuration file
  BACKUP_FILE="$BACKUP_DIR/SEP${macaddress}_$(date +%Y%m%d%H%M%S).cnf.xml"
  echo "Backing up existing file to $BACKUP_FILE"
  cp -v "$CONFIG_FILE" "$BACKUP_FILE"

  # Delete the original file
  echo "Deleting original configuration file: $CONFIG_FILE"
  rm -v "$CONFIG_FILE"
fi

# Create the new configuration file by copying and updating the template
echo -e "\nCopying and updating template file to create $CONFIG_FILE"
cp -v "$TEMPLATE_FILE" "$CONFIG_FILE"
sed -i 's/--SEPMAC--/SEP'"$macaddress"'/' "$CONFIG_FILE"
sed -i 's/--EXTENNUMBER--/'"$extension"'/' "$CONFIG_FILE"

# Update permissions and reload configurations
echo -e "\nUpdating permissions and reloading Asterisk configurations"
chown tftp "$TFTPBOOT_PATH" -R
asterisk -x 'dialplan reload'
asterisk -x 'sip reload'

# Run the Python script to reboot the phone
if [ -f "$REBOOT_SCRIPT" ]; then
  echo -e "\nRebooting the phone by running $REBOOT_SCRIPT"
  python3 "$REBOOT_SCRIPT"
else
  echo -e "\nReboot script not found at $REBOOT_SCRIPT. Skipping phone reboot."
fi

echo -e "\nConfiguration complete! The phone is now registered."

