<?php
/**
 * SOS POWER API PROXY
 */
header('Content-Type: application/json');

$action = $_GET['action'] ?? 'status';
$level = $_GET['level'] ?? 1.0;
$drain = $_GET['drain'] ?? 0.05;
$profile = $_GET['profile'] ?? 'TACTICAL';

// Java Backend Interaction
$javaUrl = "http://localhost:8080/mind/power?action=" . $action . "&level=" . $level . "&drain=" . $drain . "&profile=" . $profile;

echo file_get_contents($javaUrl);
