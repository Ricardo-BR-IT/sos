-- 2026-02-17: Profile language preferences keyed by local Node ID (v7_node_id)
CREATE TABLE IF NOT EXISTS user_preferences (
    node_id VARCHAR(80) PRIMARY KEY,
    language VARCHAR(5) NOT NULL DEFAULT 'en',
    country_detected VARCHAR(2) NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE INDEX idx_user_preferences_language ON user_preferences (language);
CREATE INDEX idx_user_preferences_country ON user_preferences (country_detected);
