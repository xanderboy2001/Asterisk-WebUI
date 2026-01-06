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
								<form method="post">
										<?php foreach ($scripts as $name => $path): ?>
												<button class=script type="submit">
														<?php echo htmlspecialchars($name); ?>
												</button>
										<?php endforeach ?>
								</form>
						</div>
						<div class="cards inout-card">
								Input/Output Card
						</div>
						<div class="cards help-card">
								Help Card
						</div>
				</div>
		</div>
<!--
    <form method="post">
				<label for="script-select">Choose a script:</label>

        <select name="script_selection" id="script-select">

						<option value="" disabled selected>- Choose a script -</option>

            <?php
            // Dynamically create a button for every script defined in $scripts array
            foreach ($scripts as $name => $path):
            ?>
								<option value="<?php echo htmlspecialchars($name); ?>">
										<?php echo htmlspecialchars($name); ?>
								</option>
            <?php endforeach; ?>
        </select>

				<button type="submit" name="execute_script" value="1">Run Script</button>

				<button type="submit" name="reset" value="1">Reset Output</button>
    </form>

    <?php
    // Display script execution results if available
    if ($output):
				?>
				<hr>
        <h2>Output:</h2>
        <pre><?= htmlspecialchars($output) ?></pre>
		<?php endif; ?>
-->
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
