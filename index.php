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
																data-path="<?php echo htmlspecialchars($path['path']); ?>">
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
										<div class="card-content">
												Help Card
										</div>
						</div>
				</div>
		</div>
<script>
const SCRIPT_DEFINITIONS = <?php echo json_encode($scripts, JSON_HEX_TAG | JSON_HEX_APOS); ?>;
</script>
<script>
document.addEventListener('DOMContentLoaded', () => {
		const buttons = document.querySelectorAll('.script-button');
		const scriptNameLabel = document.getElementById('script-name');
		const helpCard = document.querySelector(".help-card .card-content");
		const ioCard = document.getElementById("io-output");
		let selectedButton = null;

		function renderInputs(scriptName) {
				ioCard.innerHTML = `
						<span><strong>Script Name:</strong> ${scriptName}</span>
				`;

				const inputs = SCRIPT_DEFINITIONS[scriptName].inputs;

				if (!SCRIPT_DEFINITIONS[scriptName]) {
						console.error("Unknown script:", scriptName);
						return;
				}

				if (!inputs.length) {
						ioCard.insertAdjacentHTML(
								"beforeend",
								"<em>No input required</em>"
						);
						return;
				}

				inputs.forEach((def, index) => {
						const wrapper = document.createElement("div");
						wrapper.className = "input-group";

						const input = document.createElement("input");
						input.type = def.type;
						input.placeholder = def.placeholder ?? "";
						input.dataset.index = index;

						if (def.is_extension) {
								input.type = "text";
								input.inputMode = "numeric";
								input.pattern = "\\d{4}";
								input.placeholder = "4-digit extension";
						}

						if (def.is_mac) {
								input.pattern = "[0-9a-fA-f:]{12,17}";
						}

						wrapper.appendChild(input);
						ioCard.appendChild(wrapper);
				});
		}
								

		buttons.forEach(btn => {
				btn.addEventListener('click', () => {
						if (selectedButton === btn) {
								btn.classList.remove('selected');
								selectedButton = null;
								scriptNameLabel.innerHTML = `
										<span><strong>Script Name:</strong> No script selected</span>
								`;
								helpCard.textContent = "Help Card";
						} else {
								if (selectedButton) selectedButton.classList.remove('selected');
										btn.classList.add('selected');
										selectedButton = btn;
										const scriptName = btn.dataset.script;
										scriptNameLabel.textContent = scriptName;
										renderInputs(scriptName);

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
