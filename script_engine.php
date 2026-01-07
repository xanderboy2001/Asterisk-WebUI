<?php
// Configuration: Define script directory (Development vs Production paths)
#$scripts_path = '/var/lib/tftpboot';
$scripts_path = 'scripts';

// Array mapping GUI button labels to specific shell script paths
$scripts = [
		'Reload' => [
				"path" => "$scripts_path/asterisk_reload.sh",
				"inputs" => []
		],
		'Check Free Extensions' => [
				"path" => "$scripts_path/check_free_exten.sh",
				"inputs" => [
						[
                "is_extension" => true,
						]
				]
		],
		'Check MAC Address' => [
				"path" => "$scripts_path/check_mac.sh",
				"inputs" => [
						[
								"type" => "text",
								"is_mac" => true,
								"placeholder" => "MAC address"
						]
				]
		],
		'Delete Extensions' => [
				"path" => "$scripts_path/delete_exten.sh",
				"inputs" => [
						[
                "is_extension" => true,
						]
				]
		],
		'Delete Phone' => [
				"path" => "$scripts_path/delete_phone.sh",
				"inputs" => [
						[
								"type" => "text",
								"is_mac" => true,
								"placeholder" => "MAC address"
						]
				]
		],
		'Delete Voicemail' => [
				"path" => "$scripts_path/delete_voicemail.sh",
				"inputs" => [
						[
                "is_extension" => true,
						]
				]
		],
		'Generate Phone List' => [
				"path" => "$scripts_path/generate_phone_list.sh",
				"inputs" => []
		],
		'Reboot All Phones' => [
				"path" => "$scripts_path/reboot_all_phones.sh",
				"inputs" => []
		],
		'Reboot Single Phone' => [
				"path" => "$scripts_path/reboot_phone.sh",
				"inputs" => [
						[
                "is_extension" => true,
						]
				]
		],
		'Redirect Extension' => [
				"path" => "$scripts_path/redirect_exten.sh",
				"inputs" => [
						[
                "is_extension" => true,
						],
						[
                "is_extension" => true,
						]
				]
		],
		'Refresh Phone Config' => [
				"path" => "$scripts_path/refresh_phone_config.sh",
				"inputs" => [
						[
                "is_extension" => true,
						]
				]
		],
		'Register x7912' => [
				"path" => "$scripts_path/register_7912.sh",
				"inputs" => [
						[
								"type" => "text",
								"is_mac" => true,
								"placeholder" => "MAC address of new phone"
						],
						[
                "is_extension" => true,
						],
						[
								"type" => "text",
								"placeholder" => "Name of phone owner"
						]
				]
		],
		'Register x7960' => [
				"path" => "$scripts_path/register_7960.sh",
				"inputs" => [
						[
								"type" => "text",
								"is_mac" => true,
								"placeholder" => "MAC address of new phone"
						],
						[
                "is_extension" => true,
						],
						[
								"type" => "text",
								"placeholder" => "Name of phone owner"
						],
						[
								"type" => "text",
								"placeholder" => "Email of phone owner"
						]
				]
		],
		'Remove Config' => [
				"path" => "$scripts_path/remove_config.sh",
				"inputs" => [
						[
                "is_extension" => true,
						],
						[
								"type" => "text",
								"is_mac" => true,
								"placeholder" => "MAC Address"
						]
				]
		],
		'Replace x7940' => [
				"path" => "$scripts_path/replace_7940.sh",
				"inputs" => [
						[
								"type" => "text",
								"is_mac" => true,
								"placeholder" => "Old MAC address"
						],
						[
								"type" => "text",
								"is_mac" => true,
								"placeholder" => "New MAC address"
						]
				]
		],
		'Replace Phone' => [
				"path" => "$scripts_path/replace_phone.sh",
				"inputs" => [
						[
								"type" => "text",
								"is_mac" => true,
								"placeholder" => "Old MAC address"
						],
						[
								"type" => "text",
								"is_mac" => true,
								"placeholder" => "New MAC address"
						]
				]
		],
		'Re-Register x7960' => [
				"path" => "$scripts_path/reregister_7960.sh",
				"inputs" => [
						[
								"type" => "text",
								"is_mac" => true,
								"placeholder" => "MAC address of phone"
						],
						[
                "is_extension" => true,
						],
						[
								"type" => "text",
								"placeholder" => "Name of phone owner"
						],
						[
								"type" => "text",
								"placeholder" => "Email of phone owner"
						]
				]
		],
		'Reset Voicemail Password' => [
				"path" => "$scripts_path/reset_vm_password.sh",
				"inputs" => [
						[
                "is_extension" => true,
						],
						[
								"type" => "number",
								"placeholder" => "New PIN"
						]
				]
		],
		'Unregister Phone' => [
				"path" => "$scripts_path/unregister_phone.sh",
				"inputs" => [
						[
                "is_extension" => true,
						]
				]
		],
		'View Active Calls' => [
				"path" => "$scripts_path/view_active_calls.sh",
				"inputs" => []
		],
		'View Call History' => [
				"path" => "$scripts_path/view_call_history.sh",
				"inputs" => [
						[
                "is_extension" => true,
						]
				]
		],
		'View Extension Dialplan' => [
				"path" => "$scripts_path/view_exten_dialplan.sh",
				"inputs" => [
						[
                "is_extension" => true,
						]
				]
		],
		'View Offline Phones' => [
				"path" => "$scripts_path/view_offline_phones.sh",
				"inputs" => []
		],
		'Delete Voicemail Config' => [
				"path" => "$scripts_path/VM_delete.sh",
				"inputs" => [
						[
                "is_extension" => true,
						]
				]
		]
];

function sanitize_input(string $input, array $rules = []): string {
		$input = trim($input);
		$input = stripslashes($input);
		$input = htmlspecialchars($input);

		if (isset($rules['type'])) {
				switch ($rules['type']) {
						case 'number':
								$input = preg_replace('/\D/', '', $input);
								break;
						case 'mac':
								$input = preg_replace('/[^0-9a-fA-F:]/', '', $input);
								break
				}
		}

		return $input;
}

function validate_input(string $input, array $rules = []): bool {
		if (isset($rules['type'])) {
				switch ($rules['type']) {
						case 'number':
								if (isset($rules['length']) && strlen($input) !== $rules['length']) {
										return false;
								}
								if (!ctype_digit($input)) return false;
								break;
						case 'mac':
								if (!preg_match('/^([0-9A-Fa-f]{2}[:-]?){5}[0-9A-Fa-f]{2}$/', $input)) {
										return false;
								}
								break;
						case 'text':
								break;
				}
		}

		return true;
}

/**
 * Validates script existence and executes it via shell.
 * Returns the output (stdout and stderr).
 */
function run_script(string $script_name, array $scripts, ?string $input = null): string
{
    if (!array_key_exists($script_name, $scripts)) {
        return "Invalid script selected.";
    }

		$scriptDef = $scripts[$script_name];
		$sanitized_inputs = [];

		foreach ($scriptDef['inputs'] as $index => $inputDef) {
				$raw = $inputs[$index] ?? '';
				$sanitized = sanitize_input($raw, $inputDef);

				if (!validate_input($sanitized, $inputDef)) {
						return "Invalid input at position $index: " . htmlspecialchars($raw);
				}

				$sanitized_inputs[] = $sanitized;
		}

		$cmd = escapeshellcmd($scriptDef['path']);
		foreach ($sanitized_inputs as $arg) {
				$cmd .= ' ' . escapeshellarg($arg);
		}

		return shell_exec($cmd . " 2>&1");
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
