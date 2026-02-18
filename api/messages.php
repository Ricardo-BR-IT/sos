<?php
// API: MESSAGING SYSTEM (V7.2)
// Handles: Send (POST), Receive (GET)

// ENABLE DEBUGGING (DISABLED FOR PRODUCTION)
// ini_set('display_errors', 1);
// error_reporting(E_ALL);

header('Content-Type: application/json');
require_once 'db.php';

$method = $_SERVER['REQUEST_METHOD'];
$pdo = getDB();

try {
    if ($method === 'POST') {
        // SEND MESSAGE
        $input = json_decode(file_get_contents('php://input'), true);
        if (!$input) throw new Exception("Invalid JSON Payload");

        $sender = $input['sender_id'] ?? 'UNKNOWN';
        $channel = $input['channel'] ?? 'PUBLIC'; // 'PUBLIC' or Target ID
        $content = $input['content'] ?? '';

        if (empty($content)) throw new Exception("Empty message");

        // Validate: If Private, check if target exists (Optional, skipping for speed)

        $sql = "INSERT INTO messages (sender_id, channel, content, timestamp) VALUES (:sender, :channel, :content, NOW())";
        $stmt = $pdo->prepare($sql);
        $stmt->execute([
            ':sender' => $sender,
            ':channel' => $channel,
            ':content' => $content
        ]);

        echo json_encode(['status' => 'OK']);

    } elseif ($method === 'GET') {
        // RECEIVE MESSAGES
        // FIX: Removed 'since' timestamp filter to avoid client clock sync issues.
        // Always returns last 50 relevant messages. Client handles deduplication.
        
        $myId = $_GET['my_id'] ?? '';

        // Fetch PUBLIC messages OR Private messages sent TO me OR sent BY me
        $sql = "SELECT * FROM (
                    SELECT * FROM messages 
                    WHERE channel = 'PUBLIC' 
                    OR channel = :my_id 
                    OR sender_id = :my_id
                    ORDER BY timestamp DESC LIMIT 50
                ) sub
                ORDER BY timestamp ASC";
        
        $stmt = $pdo->prepare($sql);
        $stmt->execute([
            ':my_id' => $myId
        ]);

        echo json_encode(['messages' => $stmt->fetchAll()]);
    }

} catch (Exception $e) {
    http_response_code(500);
    echo json_encode(['error' => $e->getMessage()]);
}
?>
