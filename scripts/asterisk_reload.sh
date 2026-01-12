#!/usr/bin/env bash
set -euo pipefail

# --- HELP ---
# Reloads key Asterisk configuration components without restarting the service.
#
# Inputs / Expectations:
# - No command-line arguments.
# - Asterisk must already be running.
# - 'asterisk' CLI must be available in PATH.
# - Script must be run as root or a user permitted to run `asterisk -rx`.
# - Assumes legacy SIP (chan_sip), not PJSIP.
#
# Behavior:
# - Verifies the Asterisk process is running; exits with error if not.
# - Reloads configurations in this order:
#     1. Voicemail
#     2. SIP signaling
#     3. Dialplan
#
# Impact:
# - Applies config changes without a full restart.
# - Existing calls are generally preserved; new calls use updated configs.
# ------------


if [[ "${TESTING:-0}" == "1" ]]; then
	echo "[TEST MODE]"
	echo "Script: $0"
	echo "Arguments: $*"
	exit 0
fi


# Check if Asterisk is running
if ! pgrep -x "asterisk" > /dev/null; then
    echo "Error: Asterisk is not running. Please start Asterisk and try again."
    exit 1
fi

# Reload voicemail
echo "Reloading voicemail configuration..."
asterisk -rx "voicemail reload"
echo "Voicemail configuration reloaded."

# Reload SIP configuration
echo "Reloading SIP configuration..."
asterisk -rx "sip reload"
echo "SIP configuration reloaded."

# Reload dialplan
echo "Reloading dialplan..."
asterisk -rx "dialplan reload"
echo "Dialplan reloaded."

echo "All configurations reloaded successfully."

