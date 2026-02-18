<?php
// API: SIGNAL PROXY (V25)
// Routes Morse Audio requests to the local Java Agent Engine

$query = $_GET['q'] ?? '';
if (empty($query)) {
    http_response_code(400);
    echo json_encode(["error" => "Missing q parameter"]);
    exit;
}

$targetUrl = "http://localhost:8080/mind/signal?q=" . urlencode($query);

// Stream the binary response directly
header('Content-Type: audio/wav');
header('Content-Disposition: attachment; filename="sos_signal.wav"');

$ctx = stream_context_create(['http' => ['timeout' => 5]]);
$fp = @fopen($targetUrl, 'rb', false, $ctx);

if ($fp) {
    fpassthru($fp);
    fclose($fp);
} else {
    // Fallback: This would normally be handled by a local generator, 
    // but here we just return an error if the Java server is down.
    http_response_code(503);
    header('Content-Type: application/json');
    echo json_encode(["error" => "Java Signal Engine Offline"]);
}
?>
