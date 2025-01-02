<?php
// #ddev-generated
// xhgui_prepend.php is copied to xhprof_prepend.php to set up xhgui
// Overrides DDEV's built in xhprof handler.
$homeDir = getenv('HOME');
$globalAutoload = $homeDir . '/.composer/vendor/autoload.php';
if (file_exists($globalAutoload)) {
    require_once $globalAutoload;
    // echo "Global autoloader loaded successfully from: $globalAutoload\n";
} else {
    error_log("Global autoloader not found at: $globalAutoload");
}
if (file_exists("/mnt/ddev_config/xhgui/collector/xhgui.collector.php")) {
    require_once "/mnt/ddev_config/xhgui/collector/xhgui.collector.php";
}
