<?php
/**
 * SOS SECURITY API PROXY
 */
header('Content-Type: application/json');

$action = $_GET['action'] ?? 'status';

// Java Backend Interaction
$javaUrl = "http://localhost:8080/mind/security?action=" . $action;

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $postData = file_get_contents('php://input');
    $opts = [
        'http' => [
            'method'  => 'POST',
            'header'  => 'Content-Type: application/json',
            'content' => $postData
        ]
    ];
    $context = stream_context_create($opts);
    echo file_get_contents($javaUrl, false, $context);
} else {
    echo file_get_contents($javaUrl);
}
