<?php
require 'script_engine.php';

$data = json_decode(file_get_contents('php://input'), true);

$script = $data['script'] ?? null;
$inputs = $data['inputs'] ?? [];

if (!$script || !isset($scripts[$script])) {
		http_response_code(400);
		echo "Invalid script.";
		exit;
}

// Just show what will be run for now
echo "Script: $script\n";
echo "Inputs:\n";

foreach ($inputs as $i => $input) {
		echo "   [$i] $input\n";
}
