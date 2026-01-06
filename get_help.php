<?php
if (isset($_GET['path'])) {
		$path = $_GET['path'];

		if (file_exists($path)) {
				$contents = file_get_contents($path);

				preg_match('/# --- HELP ---(.*?)# ------------/s', $contents, $matches);

				if (isset($matches[1])) {
						$help = trim(str_replace("#", "", $matches[1]));
						echo $help;
				} else {
						echo "No help information found.";
				}
		} else {
				echo "Script not found.";
		}
}
?>
