<?php
// API: VERSION CHECK (V15)
header('Content-Type: application/json');

echo json_encode([
    'version' => '15.0.0',
    'codename' => 'PATHFINDER',
    'build' => 20260215,
    'urgent' => false
]);
?>
