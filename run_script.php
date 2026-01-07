<?php
include 'script_engine.php'
// Handle Form Submission
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
		$data = json_decode(file_get_contents('php://input'), true);
		$script_name = $data['script'] ?? null;
		$inputs = $data['inputs'] ?? [];

		header('Content-Type: application/json');

		if (!$script_name || !isset($scripts[$script_name])) {
				echo json_encode(['success' => false, 'message' => 'Invalid script.']);
				exit;
		}

		$output = run_script($script_name, $scripts, $inputs);
		echo json_encode(['success' => true, 'output' => $output]);
		exit;
}
?>
