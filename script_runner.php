<?php
// Configuration: Define script directory (Development vs Production paths)
#$scripts_path = '/var/lib/tftpboot';
$scripts_path = 'scripts';

// Array mapping GUI button labels to specific shell script paths
$scripts = [
    'Reload' => "$scripts_path/asterisk_reload.sh",
    'Check Free Extensions' => "$scripts_path/check_free_exten.sh",
    'Check MAC Address' => "$scripts_path/check_mac.sh",
    'Delete Extensions' => "$scripts_path/delete_exten.sh",
    'Delete Phone' => "$scripts_path/delete_phone.sh",
    'Delete Voicemail' => "$scripts_path/delete_voicemail.sh",
    'Edit System Files' => "$scripts_path/edit_system_files.sh",
    'Generate Phone List' => "$scripts_path/generate_phone_list.sh",
    'Reboot All Phones' => "$scripts_path/reboot_all_phones.sh",
    'Reboot Single Phone' => "$scripts_path/reboot_phone.sh",
    'Redirect Extension' => "$scripts_path/redirect_exten.sh",
    'Refresh Phone Config' => "$scripts_path/refresh_phone_config.sh",
    'Register x7912' => "$scripts_path/register_7912.sh",
    'Register x7960' => "$scripts_path/register_7960.sh",
    'Remove Config' => "$scripts_path/remove_config.sh",
    'Replace x7940' => "$scripts_path/replace_7940.sh",
    'Replace Phone' => "$scripts_path/replace_phone.sh",
    'Re-Register x7960' => "$scripts_path/reregister_7960.sh",
    'Reset Voicemail Password' => "$scripts_path/reset_vm_password.sh",
    'Unregister Phone' => "$scripts_path/unregister_phone.sh",
    'View Active Calls' => "$scripts_path/view_active_calls.sh",
    'View Call History' => "$scripts_path/view_call_history.sh",
    'View Extension Dialplan' => "$scripts_path/view_exten_dialplan.sh",
    'View Offline Phones' => "$scripts_path/view_offline_phones.sh",
    'Delete Voicemail Config' => "$scripts_path/VM_delete.sh"
];

/**
 * Validates script existence and executes it via shell.
 * Returns the output (stdout and stderr).
 */
function run_script(string $script_name, array $scripts, ?string $input = null): string
{
		# Bypass this function for testing
		return "This is where I'd put my output...";


    if (!array_key_exists($script_name, $scripts)) {
        return "Invalid script selected.";
    }

    // Escape command to prevent arbitrary command execution
    $command = escapeshellcmd($scripts[$script_name]);

    return shell_exec($command . " 2>&1");
}

$output = '';

// Handle Form Submission
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    // Run the selected script
    if (isset($_POST['execute_script'])) {
				if (isset($_POST['script_selection'])) {
						$selected = $_POST['script_selection'];
						$output = run_script($selected, $scripts, null);
				}
    }
    // Clear the output display
    if (isset($_POST['reset'])) {
        $output = '';
    }
}
?>
