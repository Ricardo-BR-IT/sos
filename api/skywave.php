<?php
/**
 * SOS SKYWAVE API PROXY
 */
header('Content-Type: application/json');

$action = $_GET['action'] ?? 'status';
$query = $_GET['q'] ?? '';

// Java Backend Interaction
$javaUrl = "http://localhost:8080/mind/skywave?action=" . $action . "&q=" . urlencode($query);

if ($action === 'send') {
    // Return Audio Stream directly
    header('Content-Type: audio/wav');
    echo file_get_contents($javaUrl);
} else {
    // Return JSON status/conditions
    echo file_get_contents($javaUrl);
}
