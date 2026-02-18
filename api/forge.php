<?php
/**
 * SOS MESH FORGE API PROXY
 */
header('Content-Type: application/json');

$action = $_GET['action'] ?? 'poll';
$worker = $_GET['worker'] ?? 'unknown';

// Java Backend Interaction
$javaUrl = "http://localhost:8080/mind/forge?action=" . $action . "&worker=" . $worker;

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
