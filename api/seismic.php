<?php
// API: SEISMIC PROXY (V30)
// Routes vibration data to the local Java Agent Engine

header('Content-Type: application/json');

$data = $_GET['d'] ?? '';

if (!$data) {
    echo json_encode(["status" => "IDLE"]);
    exit;
}

$url = "http://localhost:8080/mind/seismic?d=" . urlencode($data);

try {
    $ctx = stream_context_create(['http' => ['timeout' => 1]]);
    $response = @file_get_contents($url, false, $ctx);
    echo ($response === false) ? json_encode(["error" => "Engine Down"]) : $response;
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode(["error" => $e->getMessage()]);
}
?>
