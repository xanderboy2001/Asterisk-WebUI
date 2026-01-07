#!/usr/bin/env bash
set -euo pipefail

# --- HELP ---
# Re-creates a SEP file for a 7965 IP Phone without modifying Asterisk config files.
#
# Inputs / Expectations:
# - Prompts for MAC address, extension number, caller name, and email.
# - Uses /var/lib/tftpboot as the TFTP directory.
#
# Behavior:
# - Copies SEP0000000.cnf.xml template to a new SEP<MAC>.cnf.xml file.
# - Updates the new SEP file with the provided MAC and extension number.
# - Does NOT change sip.conf, extensions.conf, or voicemail.conf.
# - Reloads Asterisk SIP, dialplan, and voicemail services.
# - Ensures TFTP directory ownership is set to user 'tftp'.
# ------------

if [[ "${TESTING:-0}" == "1" ]]; then
	echo "[TEST MODE]"
	echo "Script: $0"
	echo "Arguments: $*"
	exit 0
fi

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
echo What is the caller email
read -p 'Caller email address: ' email

echo You entered a MAC address of $macaddress 
echo Your primary line number is $linenumber
echo -
echo -
echo Copying template file
cp -v "$TFTPBOOT_PATH/SEP0000000.cnf.xml" "$TFTPBOOT_PATH/SEP${macaddress}.cnf.xml"
echo -
echo -
echo Updating File
sed -i 's/--SEPMAC--/'SEP"$macaddress"'/' "$TFTPBOOT_PATH/SEP${macaddress}.cnf.xml"
sed -i 's/--EXTENNUMBER--/'"$linenumber"'/' "$TFTPBOOT_PATH/SEP${macaddress}.cnf.xml"
echo -
echo -
#echo -
#echo Ok now we need to create an entry in sip.conf 
#echo it will look like this
#echo -
#echo '[SEP'${macaddress}'](phone)' >> /etc/asterisk/sip.conf
#echo authname=SEP${macaddress}  >> /etc/asterisk/sip.conf
#echo secret=SEP${macaddress}  >> /etc/asterisk/sip.conf
#echo 'callerid="'${callername}'" <'${linenumber}'>'  >> /etc/asterisk/sip.conf
#echo mailbox=${linenumber}@default  >> /etc/asterisk/sip.conf
#echo ''  >> /etc/asterisk/sip.conf
#echo ''  >> /etc/asterisk/sip.conf
#echo and in extensions.conf 
#echo - 
asterisk -rx "sip reload" 
#echo 'exten => '${linenumber}',1,Dial(SIP/SEP'${macaddress}',14,t)'  >> /etc/asterisk/extensions.conf
#echo 'exten => '${linenumber}',n,Voicemail('${linenumber}',u)'  >> /etc/asterisk/extensions.conf
#echo -
#echo and in voicemail.conf
#echo ${linenumber} ' = ' ${linenumber}',' ${callername}',' ${email}',,attach=yes|delete=1' >> /etc/asterisk/voicemail.conf

chown tftp "$TFTPBOOT_PATH" -R
asterisk -x 'dialplan reload'
asterisk -x 'voicemail reload'
asterisk -x 'sip reload'
