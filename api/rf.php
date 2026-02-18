<?php
/**
 * SOS RF SCANNER API PROXY
 */
header('Content-Type: application/json');

$action = $_GET['action'] ?? 'list';
$freq = $_GET['freq'] ?? '0';
$rssi = $_GET['rssi'] ?? '0';
$bearing = $_GET['bearing'] ?? '0';

// Java Backend Interaction
$javaUrl = "http://localhost:8080/mind/rf-scan?action=" . $action . "&freq=" . urlencode($freq) . "&rssi=" . $rssi . "&bearing=" . $bearing;

echo file_get_contents($javaUrl);
