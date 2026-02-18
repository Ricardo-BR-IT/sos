<?php

declare(strict_types=1);

header('Content-Type: application/json; charset=utf-8');

require_once __DIR__ . '/db.php';
require_once __DIR__ . '/../includes/lang_bootstrap.php';

function profile_error(int $code, string $message): void
{
    http_response_code($code);
    echo json_encode(['status' => 'error', 'message' => $message], JSON_UNESCAPED_UNICODE);
    exit;
}

function profile_ok(array $payload): void
{
    echo json_encode(array_merge(['status' => 'ok'], $payload), JSON_UNESCAPED_UNICODE);
    exit;
}

function ensure_profile_table(PDO $pdo): void
{
    $sql = <<<SQL
CREATE TABLE IF NOT EXISTS user_preferences (
    node_id VARCHAR(80) PRIMARY KEY,
    language VARCHAR(5) NOT NULL DEFAULT 'en',
    country_detected VARCHAR(2) NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
SQL;

    $pdo->exec($sql);
}

function normalize_node_id($value): ?string
{
    if (!is_string($value)) {
        return null;
    }
    $nodeId = trim($value);
    if (preg_match('/^[A-Za-z0-9_-]{3,80}$/', $nodeId) !== 1) {
        return null;
    }
    return $nodeId;
}

function normalize_language($value): ?string
{
    if (!is_string($value)) {
        return null;
    }
    $lang = strtolower(trim($value));
    if (!in_array($lang, sos_supported_languages(), true)) {
        return null;
    }
    return $lang;
}

function normalize_country($value): ?string
{
    if (!is_string($value)) {
        return null;
    }
    $country = strtoupper(trim($value));
    if ($country === '') {
        return null;
    }
    if (preg_match('/^[A-Z]{2}$/', $country) !== 1) {
        return null;
    }
    return $country;
}

$method = $_SERVER['REQUEST_METHOD'] ?? 'GET';

try {
    $pdo = getDB();
    ensure_profile_table($pdo);

    if ($method === 'GET') {
        $nodeId = normalize_node_id($_GET['node_id'] ?? null);
        if ($nodeId === null) {
            profile_error(400, 'node_id is required and must be alphanumeric (3-80).');
        }

        $stmt = $pdo->prepare(
            'SELECT node_id, language, country_detected, created_at, updated_at FROM user_preferences WHERE node_id = :node_id LIMIT 1'
        );
        $stmt->execute([':node_id' => $nodeId]);
        $row = $stmt->fetch(PDO::FETCH_ASSOC);

        if (!$row) {
            profile_ok([
                'profile' => [
                    'node_id' => $nodeId,
                    'language' => null,
                    'country_detected' => null,
                    'created_at' => null,
                    'updated_at' => null,
                ],
            ]);
        }

        profile_ok(['profile' => $row]);
    }

    if ($method === 'POST') {
        $inputRaw = file_get_contents('php://input');
        $input = json_decode($inputRaw ?: '', true);
        if (!is_array($input)) {
            $input = $_POST;
        }

        $nodeId = normalize_node_id($input['node_id'] ?? null);
        $language = normalize_language($input['language'] ?? null);
        $country = normalize_country($input['country_detected'] ?? null);

        if ($nodeId === null) {
            profile_error(400, 'node_id is required and must be alphanumeric (3-80).');
        }
        if ($language === null) {
            profile_error(400, 'language is required and must be one of supported languages.');
        }

        $stmt = $pdo->prepare(
            'INSERT INTO user_preferences (node_id, language, country_detected)
             VALUES (:node_id, :language, :country_detected)
             ON DUPLICATE KEY UPDATE
               language = VALUES(language),
               country_detected = VALUES(country_detected),
               updated_at = CURRENT_TIMESTAMP'
        );
        $stmt->execute([
            ':node_id' => $nodeId,
            ':language' => $language,
            ':country_detected' => $country,
        ]);

        $read = $pdo->prepare(
            'SELECT node_id, language, country_detected, created_at, updated_at FROM user_preferences WHERE node_id = :node_id LIMIT 1'
        );
        $read->execute([':node_id' => $nodeId]);
        $profile = $read->fetch(PDO::FETCH_ASSOC);

        profile_ok(['profile' => $profile ?: [
            'node_id' => $nodeId,
            'language' => $language,
            'country_detected' => $country,
        ]]);
    }

    profile_error(405, 'Method not allowed.');
} catch (Throwable $e) {
    error_log('profile.php error: ' . $e->getMessage());
    profile_error(500, 'Internal server error.');
}
