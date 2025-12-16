<?php
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
    <?php foreach ($scripts as $name => $path): ?>
        <button type="submit" name="run_script" value="<?= htmlspecialchars($name) ?>"><?= htmlspecialchars($name) ?><br><br>
    <?php endforeach; ?>
    <button type="submit" name="reset" value="1">Reset Output</button>
    </form>
</body>
</html>