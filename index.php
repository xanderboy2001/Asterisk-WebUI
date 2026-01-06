<?php
// Include the configuration and logic handler
include 'script_runner.php';
?>

<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
		<link rel="stylesheet" href="styles.css">
    <title>Asterisk WebUI</title>
</head>

<body>
		<div class="page">
				<h1>Asterisk WebUI</h1>
				<div class="card-box">
						<div class="cards script-card">
								<div class="card-header">Scripts</div>
								<div class="card-content">
										<form method="post" class="card-content" id="script-form">
												<?php foreach ($scripts as $name => $path): ?>
												<button class="script-button" type="button"
																data-script="<?php echo htmlspecialchars($name); ?>"
																data-path="<?php echo htmlspecialchars($path); ?>">
																<?php echo htmlspecialchars($name); ?>
														</button>
												<?php endforeach ?>
										</form>
								</div>
						</div>
						<div class="cards inout-card">
								<div class="card-header">Input/Output</div>
										<div class="card-content" id="io-output">
												No script selected
										</div>
						</div>
						<div class="cards help-card">
								<div class="card-header">Help</div>
										<div class="card-content">
												Help Card
										</div>
						</div>
				</div>
		</div>
<script>
document.addEventListener('DOMContentLoaded', () => {
		const buttons = document.querySelectorAll('.script-button');
		const ioOutput = document.getElementById('io-output');
		const helpCard = document.querySelector(".help-card .card-content");
		let selectedButton = null;

		buttons.forEach(btn => {
				btn.addEventListener('click', () => {
						if (selectedButton === btn) {
								btn.classList.remove('selected');
								selectedButton = null;
								ioOutput.textContent = "No script selected";
								helpCard.textContent = "Help Card";
						} else {
								if (selectedButton) selectedButton.classList.remove('selected');
										btn.classList.add('selected');
										selectedButton = btn;
										ioOutput.textContent = btn.dataset.script;

										fetch(`get_help.php?path=${encodeURIComponent(btn.dataset.path)}`)
												.then(response => response.text())
												.then(helpText => {
														helpCard.textContent = helpText;
												})
												.catch(err => {
														helpCard.textContent = "Error loading help.";
														console.error(err);
												});
						}
				});
		});
});
</script>
<script id="__bs_script__">//<![CDATA[
  (function() {
    try {
      var script = document.createElement('script');
      if ('async') {
        script.async = true;
      }
      script.src = 'http://HOST:8001/browser-sync/browser-sync-client.js?v=3.0.4'.replace("HOST", location.hostname);
      if (document.body) {
        document.body.appendChild(script);
      } else if (document.head) {
        document.head.appendChild(script);
      }
    } catch (e) {
      console.error("Browsersync: could not append script tag", e);
    }
  })()
//]]></script>

</body>

</html>
