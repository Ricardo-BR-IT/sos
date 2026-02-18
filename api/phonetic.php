<?php
// API: PHONETIC PROXY (V27)
// Routes NATO Phonetic Alphabet requests to the local Java Agent Engine

header('Content-Type: application/json');

$query = $_GET['q'] ?? null;
$phonetic = $_GET['p'] ?? null;

if (!$query && !$phonetic) {
    http_response_code(400);
    echo json_encode(["error" => "Missing q or p parameter"]);
    exit;
}

$url = "http://localhost:8080/mind/phonetic?";
if ($query) $url .= "q=" . urlencode($query);
else $url .= "p=" . urlencode($phonetic);

try {
    $ctx = stream_context_create(['http' => ['timeout' => 2]]);
    $response = @file_get_contents($url, false, $ctx);

    if ($response === false) {
        echo json_encode(["error" => "Java Phonetic Engine Offline"]);
    } else {
        echo $response;
    }
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode(["error" => $e->getMessage()]);
}
?>
