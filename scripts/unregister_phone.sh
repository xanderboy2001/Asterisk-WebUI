#!/bin/bash

# --- HELP ---
# This script deletes a phone from the Asterisk configuration.
#
# Inputs / Behavior:
# - Prompts the user for an extension number.
# - Finds the corresponding SIP/SEP<MAC_ADDRESS> entry.
# - Removes the extension from extensions.conf.
# - Removes the phone configuration from sip.conf.
# - Deletes the corresponding XML configuration file from /var/lib/tftpboot.
# - Does not modify voicemail.conf.
# - Optionally reloads Asterisk configuration.
# ------------

# Define file paths
EXTENSIONS_CONF="/etc/asterisk/extensions.conf"
SIP_CONF="/etc/asterisk/sip.conf"
TFTPBOOT_DIR="/var/lib/tftpboot"
BACKUP_DIR="/etc/asterisk/backup"

# Check if backup directory exists; if not, create it
if [ ! -d "$BACKUP_DIR" ]; then
    mkdir -p "$BACKUP_DIR"
fi

# Backup the configuration files
cp $EXTENSIONS_CONF $BACKUP_DIR/extensions.conf.bak_$(date +%F_%T)
cp $SIP_CONF $BACKUP_DIR/sip.conf.bak_$(date +%F_%T)

# Prompt the user for the extension
read -p "Enter the extension number: " extension

# Check if the extension exists in extensions.conf
if grep -q "^exten => $extension," $EXTENSIONS_CONF; then
    echo "Extension $extension found in $EXTENSIONS_CONF."
    
    # Find the corresponding SIP/SEP<MAC_ADDRESS> entry
    sep_mac=$(grep "^exten => $extension" $EXTENSIONS_CONF | grep -oP 'SIP/SEP\K\w+')

    if [ -z "$sep_mac" ]; then
        echo "No corresponding SIP/SEP<MAC_ADDRESS> found for extension $extension."
        exit 1
    fi

    echo "Corresponding SEP MAC Address: SEP$sep_mac"

    # Remove the extension from extensions.conf
    sed -i "/^exten => $extension,/d" $EXTENSIONS_CONF
    echo "Removed extension $extension from $EXTENSIONS_CONF."

    # Remove the SEP<MAC_ADDRESS> configuration from sip.conf
    if grep -q "\[SEP$sep_mac\]" $SIP_CONF; then
        sed -i "/\[SEP$sep_mac\]/,/^$/d" $SIP_CONF
        echo "Removed configuration for SEP$sep_mac from $SIP_CONF."
    else
        echo "No configuration found for SEP$sep_mac in $SIP_CONF."
    fi

    # Remove the corresponding XML file from /var/lib/tftpboot
    xml_file="$TFTPBOOT_DIR/SEP${sep_mac}.cnf.xml"
    if [ -f "$xml_file" ]; then
        rm -f "$xml_file"
        echo "Deleted $xml_file."
    else
        echo "No XML configuration file found for SEP$sep_mac in $TFTPBOOT_DIR."
    fi

else
    echo "Extension $extension not found in $EXTENSIONS_CONF."
    exit 1
fi

# Reload Asterisk configuration (optional)
# asterisk -rx "reload"

echo "Operation completed."

