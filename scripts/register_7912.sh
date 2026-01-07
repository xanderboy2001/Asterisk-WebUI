#!/bin/bash

# --- HELP ---
# Registers a Cisco 7965 IP phone by creating a SEP/gk configuration file
# and updating Asterisk sip.conf and extensions.conf.
#
# Inputs / Expectations:
# - Prompts interactively for MAC address, line number, and caller name.
# - Uses /var/lib/tftpboot template (gk000000.txt) and cfgfmt.linux tool.
# - Requires write access to TFTP boot directory and Asterisk config files.
# - Requires Asterisk CLI access to reload SIP and dialplan.
#
# Behavior:
# - Copies and updates the template with the provided MAC and line number.
# - Generates the binary configuration file for the phone.
# - Appends SIP peer and dialplan entries to sip.conf and extensions.conf.
# - Updates permissions and reloads Asterisk SIP and dialplan configurations.
# ------------

# Define the path where the configuration files are stored
TFTPBOOT_PATH="/var/lib/tftpboot"

# Ask the user for their name
echo This script will create the SEP file for a 7965 IP Phone
echo The mac address must look like 123412341234
echo -
echo -
echo This file copies the default template and changes variables
echo -
echo -
echo - 
echo What is the Mac address of the phone. 
read -p 'MacAddress: ' macaddress
echo -
echo -
echo What is the line number
read -p 'Line Number: ' linenumber
echo -
echo -
echo What is the caller name
read -p 'Caller Name: ' callername
echo -
echo -

echo You entered a MAC address of $macaddress 
echo Your primary line number is $linenumber
echo -
echo -
echo Copying template file
cp -v "$TFTPBOOT_PATH/gk000000.txt" "$TFTPBOOT_PATH/gk${macaddress}.txt"
echo -
echo -
echo Updating File
sed -i 's/--SEPMAC--/'"$macaddress"'/' "$TFTPBOOT_PATH/gk${macaddress}.txt"
sed -i 's/--EXTENNUMBER--/'"$linenumber"'/' "$TFTPBOOT_PATH/gk${macaddress}.txt"
echo Creating Binary file
"$TFTPBOOT_PATH/cfgfmt.linux" "$TFTPBOOT_PATH/gk${macaddress}.txt" "$TFTPBOOT_PATH/gk${macaddress}"

echo -
echo -
echo -
echo Ok now you need to create an entry in sip.conf 
echo it should look like this
echo -
echo ''${macaddress}'](phone)' >> /etc/asterisk/sip.conf
echo authname=${macaddress} >> /etc/asterisk/sip.conf
echo secret=${macaddress} >> /etc/asterisk/sip.conf
echo 'callerid="'${callername}'" <'${linenumber}'>' >> /etc/asterisk/sip.conf
echo mailbox=${linenumber} >> /etc/asterisk/sip.conf
echo 
echo 
echo and in extensions.conf 
echo - 
echo 'exten => '${linenumber}',1,Dial(SIP/'${macaddress}',14,)' >> /etc/asterisk/extensions.conf
echo 'exten => '${linenumber}',n,Voicemail('${linenumber}')' >> /etc/asterisk/extensions.conf

chown tftp "$TFTPBOOT_PATH" -R
asterisk -rx "sip reload"
asterisk -rx "dialplan reload"
