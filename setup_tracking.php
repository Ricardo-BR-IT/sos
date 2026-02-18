<?php
// SETUP: TRACKING FEATURES (V11)
require 'api/db.php';

try {
    $db = Database::getInstance()->getConnection();
    
    // 1. Add Columns to Nodes Table
    $sql = "ALTER TABLE nodes 
            ADD COLUMN lat DECIMAL(10, 8) NULL,
            ADD COLUMN lng DECIMAL(11, 8) NULL,
            ADD COLUMN share_loc TINYINT(1) DEFAULT 0";
            
    $db->exec($sql);
    echo "SUCCESS: Added lat/lng/share_loc columns to 'nodes'.<br>";

} catch (PDOException $e) {
    // Ignore "Duplicate column" errors
    echo "NOTE: " . $e->getMessage() . "<br>";
}
?>
