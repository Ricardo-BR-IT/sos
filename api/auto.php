<?php
// API: AUTO PROXY (V29)
// Universal Signal Identification Proxy

header('Content-Type: application/json');

$q = $_GET['q'] ?? '';

if (!$q) {
    echo json_encode(["type" => "UNKNOWN"]);
    exit;
}

$url = "http://localhost:8080/mind/auto?q=" . urlencode($q);

try {
    $ctx = stream_context_create(['http' => ['timeout' => 2]]);
    $response = @file_get_contents($url, false, $ctx);
    echo ($response === false) ? json_encode(["error" => "Engine Down"]) : $response;
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode(["error" => $e->getMessage()]);
}
?>
