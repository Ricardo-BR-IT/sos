<?php
// API: DECODE PROXY (V26)
// Routes Morse decoder requests to the local Java Agent Engine

header('Content-Type: application/json');

$morse = $_GET['m'] ?? '';
if (empty($morse)) {
    http_response_code(400);
    echo json_encode(["error" => "Missing m parameter"]);
    exit;
}

$targetUrl = "http://localhost:8080/mind/decode?m=" . urlencode($morse);

try {
    $ctx = stream_context_create(['http' => ['timeout' => 2]]);
    $response = @file_get_contents($targetUrl, false, $ctx);

    if ($response === false) {
        echo json_encode([
            "decoded" => "Offline",
            "translated" => "Servidor de Inteligência Tática fora do ar."
        ]);
    } else {
        echo $response;
    }
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode(["error" => $e->getMessage()]);
}
?>
