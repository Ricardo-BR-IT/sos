<?php
// API: VITALS PROXY (V31)
// Routes health sensor data to the local Java Agent Engine

header('Content-Type: application/json');

$bpm = $_GET['bpm'] ?? 0;
$spo2 = $_GET['spo2'] ?? 100;

$url = "http://localhost:8080/mind/vitals?bpm=" . (int)$bpm . "&spo2=" . (int)$spo2;

try {
    $ctx = stream_context_create(['http' => ['timeout' => 1]]);
    $response = @file_get_contents($url, false, $ctx);
    echo ($response === false) ? json_encode(["error" => "Engine Down"]) : $response;
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode(["error" => $e->getMessage()]);
}
?>
