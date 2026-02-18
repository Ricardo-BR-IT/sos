<?php
// AUTO-SETUP SCRIPT
// Access this via browser to initialize tables: /ricardo/sos/setup_v7.php

require_once 'api/config.php';

echo "<h1>SOS Tactical V7 - Setup Protocol</h1>";

try {
    // 1. Connect directly to the database (User likely has no CREATE DB permission)
    $dsn = "mysql:host=" . DB_HOST . ";dbname=" . DB_NAME . ";charset=" . DB_CHARSET;
    $pdo = new PDO($dsn, DB_USER, DB_PASS);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "Connection to Server... [OK]<br>";
    echo "Database `" . DB_NAME . "` Selected... [OK]<br>";

    // 2. Create Tables
    $sql = "
    CREATE TABLE IF NOT EXISTS system_config (
        id INT AUTO_INCREMENT PRIMARY KEY,
        key_name VARCHAR(50) UNIQUE NOT NULL,
        value TEXT,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
    );

    CREATE TABLE IF NOT EXISTS nodes (
        id VARCHAR(50) PRIMARY KEY,
        name VARCHAR(100),
        type ENUM('SERVER', 'MOBILE', 'WEARABLE', 'SENSOR') DEFAULT 'MOBILE',
        status ENUM('ONLINE', 'OFFLINE', 'SOS') DEFAULT 'ONLINE',
        lat DECIMAL(10, 8),
        lng DECIMAL(11, 8),
        battery INT,
        last_seen TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        ip_address VARCHAR(45)
    );

    CREATE TABLE IF NOT EXISTS messages (
        id INT AUTO_INCREMENT PRIMARY KEY,
        sender_id VARCHAR(50),
        channel VARCHAR(20) DEFAULT 'PUBLIC',
        content TEXT,
        timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );

    CREATE TABLE IF NOT EXISTS user_preferences (
        node_id VARCHAR(80) PRIMARY KEY,
        language VARCHAR(5) NOT NULL DEFAULT 'en',
        country_detected VARCHAR(2) NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
    );
    ";

    $pdo->exec($sql);
    echo "Schema Initialization... [OK]<br>";
    echo "<h2>SYSTEM READY. Access <a href='index.php'>Dashboard</a>.</h2>";

} catch (PDOException $e) {
    die("Setup Failed: " . $e->getMessage());
}
?>
