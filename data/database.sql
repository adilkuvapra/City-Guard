-- =============================================
-- KNIGHTLEE SAFETY APP - FAKE DATABASE
-- =============================================

-- Create Tables
CREATE TABLE users (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    username TEXT NOT NULL,
    email TEXT NOT NULL UNIQUE,
    password_hash TEXT NOT NULL,
    first_name TEXT,
    last_name TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE user_profiles (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER UNIQUE,
    emergency_contacts JSON,
    night_safety_mode BOOLEAN DEFAULT 0,
    FOREIGN KEY (user_id) REFERENCES users(id)
);

CREATE TABLE incidents (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER,
    incident_type TEXT CHECK(incident_type IN (
        'harassment', 'theft', 'accident', 
        'dark_area', 'stray_dogs', 'vandalism',
        'suspicious_activity', 'other'
    )),
    description TEXT,
    latitude REAL NOT NULL,
    longitude REAL NOT NULL,
    upvotes INTEGER DEFAULT 0,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id)
);

CREATE TABLE blackspots (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    latitude REAL NOT NULL,
    longitude REAL NOT NULL,
    severity INTEGER CHECK(severity BETWEEN 1 AND 5),
    description TEXT,
    accidents_2016 INTEGER DEFAULT 0,
    accidents_2017 INTEGER DEFAULT 0,
    accidents_2018 INTEGER DEFAULT 0,
    fatalities_total INTEGER DEFAULT 0
);

CREATE TABLE sos_alerts (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER,
    latitude REAL NOT NULL,
    longitude REAL NOT NULL,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status TEXT DEFAULT 'active',
    FOREIGN KEY (user_id) REFERENCES users(id)
);

-- =============================================
-- INSERT FAKE DATA
-- =============================================

-- Fake Users
INSERT INTO users (username, email, password_hash, first_name, last_name) VALUES
('john_doe', 'john@example.com', 'hashed_pass_123', 'John', 'Doe'),
('jane_smith', 'jane@example.com', 'hashed_pass_456', 'Jane', 'Smith'),
('alex_wong', 'alex@example.com', 'hashed_pass_789', 'Alex', 'Wong'),
('sara_chen', 'sara@example.com', 'hashed_pass_012', 'Sara', 'Chen'),
('mike_brown', 'mike@example.com', 'hashed_pass_345', 'Mike', 'Brown');

-- User Profiles
INSERT INTO user_profiles (user_id, emergency_contacts, night_safety_mode) VALUES
(1, '["+911234567890", "+919876543210"]', 1),
(2, '["+911111223344"]', 0),
(3, '["+912223334455", "+913334445566"]', 1),
(4, '["+914445556677"]', 0),
(5, '["+915556667788", "+916667778899"]', 1);

-- Fake Incidents
INSERT INTO incidents (user_id, incident_type, description, latitude, longitude, upvotes, timestamp) VALUES
(1, 'harassment', 'Group of men harassing women near metro station after 9 PM', 12.9716, 77.5946, 15, '2025-12-01 20:30:00'),
(2, 'theft', 'Phone snatched near bus stop by bike riders', 12.9356, 77.6246, 8, '2025-12-02 18:45:00'),
(3, 'dark_area', 'Poor street lighting on this entire stretch after 10 PM', 12.9916, 77.5746, 22, '2025-11-30 22:15:00'),
(4, 'stray_dogs', 'Aggressive stray dogs chasing people near park', 12.9516, 77.6146, 12, '2025-12-03 19:00:00'),
(5, 'suspicious_activity', 'Suspicious individuals loitering near ATM', 12.9816, 77.6046, 5, '2025-12-04 21:30:00'),
(2, 'accident', 'Frequent bike accidents at this curve', 12.9416, 77.5846, 18, '2025-11-29 17:20:00'),
(1, 'vandalism', 'Public property damaged by unknown persons', 12.9616, 77.6246, 7, '2025-12-02 23:00:00');

-- Blackspots Data (Based on your CSV)
INSERT INTO blackspots (name, latitude, longitude, severity, description, accidents_2016, accidents_2017, accidents_2018, fatalities_total) VALUES
('MG Road Junction', 12.9716, 77.5946, 4, 'High accident zone during peak hours', 15, 18, 20, 12),
('Silk Board Junction', 12.9172, 77.6233, 5, 'Notorious for traffic chaos and accidents', 32, 35, 38, 28),
('Hebbal Flyover', 13.0359, 77.5970, 3, 'Accidents due to speeding on flyover', 10, 12, 14, 8),
('Koramangala 80ft Road', 12.9352, 77.6245, 4, 'Multiple intersection accidents', 18, 20, 22, 15),
('Jayanagar 4th Block', 12.9258, 77.5972, 2, 'Moderate accident zone', 8, 9, 10, 5),
('Electronic City Phase 1', 12.8456, 77.6654, 4, 'Heavy traffic leads to rear-end collisions', 22, 25, 28, 18),
('Majestic Bus Stand', 12.9775, 77.5707, 5, 'Pedestrian and vehicle conflict area', 40, 42, 45, 32),
('Indiranagar 100ft Road', 12.9782, 77.6401, 3, 'Accidents during night hours', 12, 14, 16, 9),
('Whitefield Main Road', 12.9698, 77.7500, 4, 'IT corridor with high-speed accidents', 25, 28, 30, 21),
('Banashankari Bus Stand', 12.9251, 77.5486, 3, 'Bus-pedestrian accidents common', 14, 15, 17, 11);

-- SOS Alerts
INSERT INTO sos_alerts (user_id, latitude, longitude, status) VALUES
(1, 12.9716, 77.5946, 'resolved'),
(3, 12.9916, 77.5746, 'active'),
(5, 12.9816, 77.6046, 'active');

-- =============================================
-- CREATE VIEWS FOR EASY ACCESS
-- =============================================

CREATE VIEW incident_summary AS
SELECT 
    i.*,
    u.first_name || ' ' || u.last_name as reporter_name,
    CASE 
        WHEN i.upvotes > 20 THEN 'High Priority'
        WHEN i.upvotes > 10 THEN 'Medium Priority'
        ELSE 'Low Priority'
    END as priority
FROM incidents i
LEFT JOIN users u ON i.user_id = u.id;

CREATE VIEW blackspot_summary AS
SELECT 
    *,
    CASE 
        WHEN severity >= 4 THEN 'Critical'
        WHEN severity = 3 THEN 'High Risk'
        ELSE 'Moderate Risk'
    END as risk_level,
    (accidents_2016 + accidents_2017 + accidents_2018) as total_accidents
FROM blackspots;

-- =============================================
-- SAMPLE QUERIES FOR YOUR FRONTEND
-- =============================================

-- Get all incidents as GeoJSON
SELECT 
    json_object(
        'type', 'FeatureCollection',
        'features', json_group_array(
            json_object(
                'type', 'Feature',
                'geometry', json_object(
                    'type', 'Point',
                    'coordinates', json_array(longitude, latitude)
                ),
                'properties', json_object(
                    'id', id,
                    'type', incident_type,
                    'description', description,
                    'upvotes', upvotes
                )
            )
        )
    ) as geojson
FROM incidents;

-- Get all blackspots
SELECT * FROM blackspots ORDER BY severity DESC;

-- Get recent incidents
SELECT * FROM incidents ORDER BY timestamp DESC LIMIT 10;

-- Count incidents by type
SELECT incident_type, COUNT(*) as count 
FROM incidents 
GROUP BY incident_type 
ORDER BY count DESC;