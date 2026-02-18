<?php
/**
 * SOS SWARM API PROXY
 */
header('Content-Type: application/json');

// Using a file-based temporary storage for Swarm state (simulation)
$stateFile = __DIR__ . '/../data/swarm_state.json';
if (!file_exists(dirname($stateFile))) mkdir(dirname($stateFile), 0777, true);

$input = json_decode(file_get_contents('php://input'), true);
$currentState = file_exists($stateFile) ? json_decode(file_get_contents($stateFile), true) : [];

if ($input && isset($input['id'])) {
    $input['lastSeen'] = time();
    $currentState[$input['id']] = $input;
}

// Clean stale nodes (> 30s)
foreach ($currentState as $id => $node) {
    if (time() - $node['lastSeen'] > 30) {
        unset($currentState[$id]);
    }
}

file_put_contents($stateFile, json_encode($currentState));

// Return all nodes
echo json_encode(array_values($currentState));
