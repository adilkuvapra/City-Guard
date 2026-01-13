-- =============================================
-- USERS DATA FOR KNIGHTLEE APP
-- =============================================

-- Create Users Table
CREATE TABLE IF NOT EXISTS users (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    username TEXT NOT NULL UNIQUE,
    email TEXT NOT NULL UNIQUE,
    password_hash TEXT NOT NULL,
    first_name TEXT,
    last_name TEXT,
    phone TEXT,
    is_active BOOLEAN DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_login TIMESTAMP
);

-- Create User Profiles Table
CREATE TABLE IF NOT EXISTS user_profiles (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER UNIQUE,
    emergency_contacts JSON DEFAULT '[]',
    night_safety_mode BOOLEAN DEFAULT 0,
    trusted_contacts JSON DEFAULT '[]',
    profile_pic_url TEXT,
    notification_enabled BOOLEAN DEFAULT 1,
    location_sharing BOOLEAN DEFAULT 0,
    FOREIGN KEY (user_id) REFERENCES users(id)
);

-- =============================================
-- INSERT FAKE USERS
-- =============================================

-- Insert Sample Users
INSERT INTO users (username, email, password_hash, first_name, last_name, phone) VALUES
('john_doe', 'john@example.com', '$2b$10$examplehash123', 'John', 'Doe', '+911234567890'),
('jane_smith', 'jane@example.com', '$2b$10$examplehash456', 'Jane', 'Smith', '+919876543210'),
('alex_wong', 'alex@example.com', '$2b$10$examplehash789', 'Alex', 'Wong', '+912345678901'),
('sara_chen', 'sara@example.com', '$2b$10$examplehash012', 'Sara', 'Chen', '+913456789012'),
('mike_brown', 'mike@example.com', '$2b$10$examplehash345', 'Mike', 'Brown', '+914567890123'),
('priya_sharma', 'priya@example.com', '$2b$10$examplehash678', 'Priya', 'Sharma', '+915678901234'),
('rahul_verma', 'rahul@example.com', '$2b$10$examplehash901', 'Rahul', 'Verma', '+916789012345'),
('ananya_patel', 'ananya@example.com', '$2b$10$examplehash234', 'Ananya', 'Patel', '+917890123456'),
('test_user', 'test@example.com', '$2b$10$testhash567', 'Test', 'User', '+918901234567');

-- Insert User Profiles
INSERT INTO user_profiles (user_id, emergency_contacts, night_safety_mode, trusted_contacts, notification_enabled) VALUES
(1, '["+911111223344", "+912222334455"]', 1, '["jane_smith", "alex_wong"]', 1),
(2, '["+913333445566"]', 0, '["john_doe", "sara_chen"]', 1),
(3, '["+914444556677", "+915555667788"]', 1, '["mike_brown", "priya_sharma"]', 1),
(4, '["+916666778899"]', 0, '["jane_smith", "rahul_verma"]', 1),
(5, '["+917777889900", "+918888990011"]', 1, '["alex_wong", "ananya_patel"]', 1),
(6, '["+919999001122"]', 0, '["priya_sharma", "mike_brown"]', 1),
(7, '["+911010101010", "+911111111111"]', 1, '["rahul_verma", "test_user"]', 1),
(8, '["+912121212121"]', 0, '["ananya_patel", "john_doe"]', 1),
(9, '["+913232323232"]', 1, '["test_user", "jane_smith"]', 1);

-- =============================================
-- USER STATISTICS VIEW
-- =============================================

CREATE VIEW IF NOT EXISTS user_statistics AS
SELECT 
    u.id,
    u.username,
    u.first_name || ' ' || u.last_name as full_name,
    u.email,
    u.created_at,
    COALESCE(up.night_safety_mode, 0) as uses_night_safety,
    json_array_length(up.emergency_contacts) as emergency_contacts_count,
    (SELECT COUNT(*) FROM incidents i WHERE i.user_id = u.id) as incidents_reported,
    (SELECT COUNT(*) FROM sos_alerts s WHERE s.user_id = u.id) as sos_count
FROM users u
LEFT JOIN user_profiles up ON u.id = up.user_id;

-- =============================================
-- SAMPLE QUERIES
-- =============================================

-- Get all users with profiles
SELECT 
    u.id, u.username, u.email, 
    u.first_name, u.last_name, u.phone,
    up.emergency_contacts,
    up.night_safety_mode,
    up.notification_enabled
FROM users u
LEFT JOIN user_profiles up ON u.id = up.user_id
ORDER BY u.created_at DESC;

-- Get active users with night safety enabled
SELECT 
    u.username,
    u.first_name || ' ' || u.last_name as full_name,
    up.emergency_contacts
FROM users u
JOIN user_profiles up ON u.id = up.user_id
WHERE up.night_safety_mode = 1
AND u.is_active = 1;

-- Get users with their incident count
SELECT 
    u.username,
    u.first_name,
    u.last_name,
    COUNT(i.id) as incidents_reported,
    SUM(i.upvotes) as total_upvotes
FROM users u
LEFT JOIN incidents i ON u.id = i.user_id
GROUP BY u.id
ORDER BY incidents_reported DESC;

-- =============================================
-- INSERT MORE FAKE USERS FOR DEMO
-- =============================================

INSERT INTO users (username, email, password_hash, first_name, last_name, phone) VALUES
('safety_hero', 'hero@example.com', '$2b$10$herowhash123', 'Safety', 'Hero', '+919191919191'),
('guardian_user', 'guardian@example.com', '$2b$10$guardhash456', 'Guardian', 'User', '+912929292929'),
('watchful_eye', 'watchful@example.com', '$2b$10$watchhash789', 'Watchful', 'Eye', '+913838383838'),
('community_helper', 'helper@example.com', '$2b$10$helphash012', 'Community', 'Helper', '+914747474747'),
('night_patrol', 'patrol@example.com', '$2b$10$patrolhash345', 'Night', 'Patrol', '+915656565656');

INSERT INTO user_profiles (user_id, emergency_contacts, night_safety_mode) VALUES
(10, '["+916161616161", "+917171717171"]', 1),
(11, '["+918181818181"]', 1),
(12, '["+919191919191", "+912020202020"]', 0),
(13, '["+913131313131"]', 1),
(14, '["+914141414141", "+915151515151"]', 1);

-- =============================================
-- CREATE USER LOGIN TOKENS TABLE (Optional)
-- =============================================

CREATE TABLE IF NOT EXISTS user_tokens (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER,
    token TEXT UNIQUE,
    expires_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id)
);

-- Insert sample tokens (for demo)
INSERT INTO user_tokens (user_id, token, expires_at) VALUES
(1, 'demo_token_john_123', datetime('now', '+7 days')),
(2, 'demo_token_jane_456', datetime('now', '+7 days')),
(3, 'demo_token_alex_789', datetime('now', '+7 days'));

-- =============================================
-- DUMMY USER LOGIN FUNCTION
-- =============================================

-- This is a simplified login check for demo purposes
-- In production, use proper hashing like bcrypt

-- Example: Check user credentials
-- SELECT * FROM users WHERE email = 'john@example.com' AND password_hash = '$2b$10$examplehash123';

-- Example: Get user with token
-- SELECT u.*, ut.token 
-- FROM users u 
-- JOIN user_tokens ut ON u.id = ut.user_id 
-- WHERE ut.token = 'demo_token_john_123' 
-- AND ut.expires_at > CURRENT_TIMESTAMP;