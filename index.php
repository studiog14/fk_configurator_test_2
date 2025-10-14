<?php
// Mobile device detection for automatic version switching
function isMobileDevice() {
    $userAgent = $_SERVER['HTTP_USER_AGENT'] ?? '';
    $mobileKeywords = [
        'Mobile', 'Android', 'iPhone', 'iPad', 'iPod', 'BlackBerry',
        'Windows Phone', 'Opera Mini', 'IEMobile', 'webOS'
    ];

    foreach ($mobileKeywords as $keyword) {
        if (stripos($userAgent, $keyword) !== false) {
            return true;
        }
    }

    return false;
}

// Check for explicit mobile/desktop request
$forceMobile = isset($_GET['mobile']) && $_GET['mobile'] === '1';
$forceDesktop = isset($_GET['desktop']) && $_GET['desktop'] === '1';

if ($forceMobile) {
    $targetFile = 'index.mobile.html';
} elseif ($forceDesktop) {
    $targetFile = 'index.html';
} elseif (isMobileDevice()) {
    $targetFile = 'index.mobile.html';
} else {
    $targetFile = 'index.html';
}

// Redirect to appropriate version
if (file_exists($targetFile)) {
    header("Location: $targetFile");
    exit;
} else {
    // Fallback if target file doesn't exist
    echo "<h1>Error: Target file '$targetFile' not found</h1>";
    echo "<p>Available files:</p>";
    echo "<ul>";
    if (file_exists('index.html')) echo "<li><a href='index.html'>Desktop Version</a></li>";
    if (file_exists('index.mobile.html')) echo "<li><a href='index.mobile.html'>Mobile Version</a></li>";
    echo "</ul>";
}
?>
