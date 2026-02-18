<?php
/**
 * SOS WI-FI SENSING API PROXY
 */
header('Content-Type: application/json');

$action = $_GET['action'] ?? 'status';

// Java Backend Interaction
$javaUrl = "http://localhost:8080/mind/sensing?action=" . $action;

echo file_get_contents($javaUrl);
