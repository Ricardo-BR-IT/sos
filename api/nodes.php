<?php
// API: NODE MANAGEMENT
// Handles: Registration (POST), Discovery (GET)

// ENABLE DEBUGGING (DISABLED FOR PRODUCTION)
// ini_set('display_errors', 1);
// error_reporting(E_ALL);

header('Content-Type: application/json');
require_once 'db.php';

$method = $_SERVER['REQUEST_METHOD'];
$pdo = getDB();

try {
    if ($method === 'POST') {
        // REGISTER / HEARTBEAT
        $input = json_decode(file_get_contents('php://input'), true);
        if (!$input) throw new Exception("Invalid JSON Payload");

        $id = $input['id'] ?? 'UNKNOWN-' . uniqid();
        $type = $input['type'] ?? 'MOBILE';
        
        $sql = "INSERT INTO nodes (id, type, lat, lng, battery, status, ip_address, name, share_loc) 
                VALUES (:id, :type, :lat, :lng, :bat, 'ONLINE', :ip, :name, :share)
                ON DUPLICATE KEY UPDATE 
                lat=:lat_u, lng=:lng_u, battery=:bat_u, status='ONLINE', last_seen=NOW(), ip_address=:ip_u, share_loc=:share_u";
        
        $stmt = $pdo->prepare($sql);
        $stmt->execute([
            ':id' => $id,
            ':type' => $type,
            ':lat' => $input['lat'] ?? 0,
            ':lng' => $input['lng'] ?? 0,
            ':bat' => $input['battery'] ?? 100,
            ':ip' => $_SERVER['REMOTE_ADDR'],
            ':name' => $input['name'] ?? $id,
            ':share' => $input['share_loc'] ?? 0,
            ':lat_u' => $input['lat'] ?? 0,
            ':lng_u' => $input['lng'] ?? 0,
            ':bat_u' => $input['battery'] ?? 100,
            ':ip_u' => $_SERVER['REMOTE_ADDR'],
            ':share_u' => $input['share_loc'] ?? 0
        ]);

        echo json_encode(['status' => 'OK', 'id' => $id]);

    } elseif ($method === 'GET') {
        // DISCOVERY
        // Cleanup old nodes (offline > 2 min)
        $pdo->exec("UPDATE nodes SET status='OFFLINE' WHERE last_seen < (NOW() - INTERVAL 2 MINUTE)");

        $stmt = $pdo->query("SELECT * FROM nodes WHERE status != 'OFFLINE'");
        echo json_encode(['nodes' => $stmt->fetchAll()]);
    }

} catch (Exception $e) {
    http_response_code(500);
    echo json_encode(['error' => $e->getMessage()]);
}
?>
