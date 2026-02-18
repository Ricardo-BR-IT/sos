<?php
// API: MIND PROXY (V24)
// Routes PWA Mind requests to the local Java Agent Engine (Port 8080)

header('Content-Type: application/json');

$method = $_SERVER['REQUEST_METHOD'];
$query = $_GET['q'] ?? '';
$agent = $_GET['agent'] ?? '';

// Java Server URL (Localhost)
$targetUrl = "http://localhost:8080/mind?q=" . urlencode($query) . "&agent=" . urlencode($agent);

try {
    // Check if Java Server is alive via CoAP or HTTP status (simplified here)
    $ctx = stream_context_create(['http' => ['timeout' => 2]]);
    $response = @file_get_contents($targetUrl, false, $ctx);

    if ($response === false) {
        // Fallback: If Java server is down, use a very basic PHP-based heuristic or return error
        echo json_encode([
            "agent" => "System Fallback",
            "response" => "O Motor de IA local (Java) parece estar offline. Recomendo verificar se o serviço 'ServerMain' está rodando no host.",
            "version" => "1.0-FALLBACK"
        ]);
    } else {
        echo $response;
    }

} catch (Exception $e) {
    http_response_code(500);
    echo json_encode(["error" => $e->getMessage()]);
}
?>
