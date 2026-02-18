<?php
// API: CODES PROXY (V28)
// Routes Tap Code and FSK requests to the local Java Agent Engine

header('Content-Type: application/json');

$type = $_GET['type'] ?? '';
$q = $_GET['q'] ?? '';

if (!$type || !$q) {
    http_response_code(400);
    echo json_encode(["error" => "Missing type or q parameter"]);
    exit;
}

$targetUrl = "http://localhost:8080/mind/codes?type=" . urlencode($type) . "&q=" . urlencode($q);

if ($type === 'fsk') {
    header('Content-Type: audio/wav');
    $ctx = stream_context_create(['http' => ['timeout' => 5]]);
    $fp = @fopen($targetUrl, 'rb', false, $ctx);
    if ($fp) {
        fpassthru($fp);
        fclose($fp);
    } else {
        http_response_code(503);
        echo json_encode(["error" => "Java Engine Offline"]);
    }
    exit;
}

try {
    $ctx = stream_context_create(['http' => ['timeout' => 2]]);
    $response = @file_get_contents($targetUrl, false, $ctx);
    echo ($response === false) ? json_encode(["error" => "Engine Down"]) : $response;
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode(["error" => $e->getMessage()]);
}
?>
