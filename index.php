<?php
// Include the configuration and logic handler
include 'script_runner.php';
?>

<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Asterisk WebUI</title>
</head>

<body>
    <h1>Asterisk WebUI</h1>
    <form method="post">
        <select name="script_name" id="script-select">

            <?php
            // Dynamically create a button for every script defined in $scripts array
            foreach ($scripts as $name => $path):
                ?>
                <option value=<?php htmlspecialchars($name) ?>><?php htmlspecialchars($name) ?></option>


            <?php endforeach; ?>
        </select>

        <button type="submit" name="reset" value="1">Reset Output</button>
    </form>

    <?php
    // Display script execution results if available
    if ($output):
        ?>
        <h2>Output:</h2>
        <pre><?= htmlspecialchars($output) ?></pre>
    <?php endif; ?>
</body>

</html>