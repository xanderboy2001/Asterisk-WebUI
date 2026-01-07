<?php
// Include the configuration and logic handler
include 'script_engine.php';
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
										<form id="script-form">
												<?php foreach ($scripts as $name => $info): ?>
												<button type="button" class="script-button" 
																data-script="<?php echo $name; ?>"
																data-path="<?php echo $info['path']; ?>">
																<?php echo htmlspecialchars($name); ?>
														</button>
												<?php endforeach ?>
										</form>
								</div>
						</div>
						<div class="cards inout-card">
								<div class="card-header">Input/Output</div>
										<div class="card-content" id="io-output">
												<span><strong>Script Name: </strong><span id="script-name">No script selected</span></span>
												<div id="dynamic-inputs"></div>
												<button id="run-script" disabled>Run Script</button>
												<pre id="script-output"></pre>
										</div>
						</div>
						<div class="cards help-card">
								<div class="card-header">Help</div>
								<div class="card-content">Help Card</div>
						</div>
				</div>
		</div>
<script>
const SCRIPT_DEFINITIONS = <?php echo json_encode($scripts, JSON_HEX_TAG | JSON_HEX_APOS); ?>;
document.addEventListener('DOMContentLoaded', () => {
		const buttons = document.querySelectorAll('.script-button');
		const scriptNameLabel = document.getElementById('script-name');
		const helpCard = document.querySelector(".help-card .card-content");
		const runButton = document.getElementById("run-script");
		let currentScript = null;

		function renderInputs(scriptName) {
				const scriptDef = SCRIPT_DEFINITIONS[scriptName];
				const inputsContainer = document.getElementById("dynamic-inputs");
				inputsContainer.innerHTML = '';

				if (!scriptDef.inputs.length) {
						inputsContainer.innerHTML = "<em>No input required</em>"
				} else {
						scriptDef.inputs.forEach((def, index) => {
								const input = document.createElement("input");

								input.dataset.index = index;
								input.type = def.type || 'text';
								input.placeholder = def.placeholder || '';
								if (def.type === 'number') input.inputMode = 'numeric';
								inputsContainer.appendChild(input);
						});
				}
				runButton.disabled = false;
		}

		runButton.addEventListener('click', () => {
				if (!currentScript) return;

				const inputs = Array.from(document.querySelectorAll('#dynamic-inputs input'))
														.map(input => input.value);

				runButton.disabled = true;
				fetch('run_script.php', {
						method: 'POST',
						headers: { 'Content-Type': 'application/json' },
						body: JSON.stringify({ script: currentScript, inputs })
				})
				.then(res => res.json())
				.then(data => {
						document.getElementById('script-output').textContent = data.success ? data.output : data.message;
				})
				.catch(err => {
						document.getElementById('script-output').textContent = 'Error running script.';
						console.error(err);
				})
				.finally(() => runButton.disabled = false);
		});

		buttons.forEach(btn => {
				btn.addEventListener('click', () => {
						if (currentScript === btn.dataset.script) {
								btn.classList.remove('selected');
								currentScript = null;
								scriptNameLabel.textContent = 'No script selected';
								runButton.disabled = true;
						} else {
								buttons.forEach(b => b.classList.remove('selected'));
								btn.classList.add('selected');
								currentScript = btn.dataset.script;
								scriptNameLabel.textContent = currentScript;
								renderInputs(currentScript);

								fetch(`get_help.php?path=${encodeURIComponent(btn.dataset.path)}`)
										.then(res => res.text())
										.then(helpText => helpCard.textContent = helpText)
										.catch(() => helpCard.textContent = 'Error loading help.');
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
