// Knightlee App - Data Loader
class KnightleeDatabase {
    constructor() {
        this.db = null;
        this.data = {
            incidents: [],
            blackspots: [],
            users: []
        };
    }

    // Initialize SQLite in browser
    async init() {
        if (!window.SQL) {
            console.error('SQL.js not loaded');
            return false;
        }

        try {
            // Create in-memory database
            this.db = new window.SQL.Database();
            
            // Load SQL schema
            const response = await fetch('data/database.sql');
            const sqlScript = await response.text();
            
            // Execute SQL
            this.db.exec(sqlScript);
            console.log('Database initialized successfully');
            
            // Load data into memory
            await this.loadAllData();
            return true;
        } catch (error) {
            console.error('Database initialization failed:', error);
            return false;
        }
    }

    // Load all data into memory
    async loadAllData() {
        try {
            // Load incidents
            const incidentsResult = this.db.exec("SELECT * FROM incidents ORDER BY timestamp DESC");
            this.data.incidents = this.parseResult(incidentsResult);
            
            // Load blackspots
            const blackspotsResult = this.db.exec("SELECT * FROM blackspots ORDER BY severity DESC");
            this.data.blackspots = this.parseResult(blackspotsResult);
            
            // Load users
            const usersResult = this.db.exec("SELECT * FROM users");
            this.data.users = this.parseResult(usersResult);
            
            console.log(`Loaded: ${this.data.incidents.length} incidents, ${this.data.blackspots.length} blackspots`);
        } catch (error) {
            console.error('Error loading data:', error);
        }
    }

    // Parse SQL.js result
    parseResult(result) {
        if (!result || result.length === 0) return [];
        const columns = result[0].columns;
        return result[0].values.map(row => {
            const obj = {};
            columns.forEach((col, index) => {
                obj[col] = row[index];
            });
            return obj;
        });
    }

    // Get all incidents
    getIncidents() {
        return this.data.incidents;
    }

    // Get all blackspots
    getBlackspots() {
        return this.data.blackspots;
    }

    // Get incidents as GeoJSON
    getIncidentsGeoJSON() {
        return {
            type: "FeatureCollection",
            features: this.data.incidents.map(incident => ({
                type: "Feature",
                geometry: {
                    type: "Point",
                    coordinates: [incident.longitude, incident.latitude]
                },
                properties: {
                    id: incident.id,
                    type: incident.incident_type,
                    description: incident.description,
                    upvotes: incident.upvotes
                }
            }))
        };
    }

    // Get blackspots as GeoJSON
    getBlackspotsGeoJSON() {
        return {
            type: "FeatureCollection",
            features: this.data.blackspots.map(spot => ({
                type: "Feature",
                geometry: {
                    type: "Point",
                    coordinates: [spot.longitude, spot.latitude]
                },
                properties: {
                    id: spot.id,
                    name: spot.name,
                    severity: spot.severity,
                    description: spot.description
                }
            }))
        };
    }

    // Add new incident
    addIncident(incident) {
        const stmt = this.db.prepare(`
            INSERT INTO incidents (incident_type, description, latitude, longitude, upvotes)
            VALUES (?, ?, ?, ?, ?)
        `);
        stmt.run([
            incident.type,
            incident.description,
            incident.latitude,
            incident.longitude,
            0
        ]);
        stmt.free();
        
        // Refresh data
        this.loadAllData();
        return { success: true, id: this.db.exec("SELECT last_insert_rowid()")[0].values[0][0] };
    }

    // Upvote incident
    upvoteIncident(id) {
        const stmt = this.db.prepare("UPDATE incidents SET upvotes = upvotes + 1 WHERE id = ?");
        stmt.run([id]);
        stmt.free();
        
        // Refresh data
        this.loadAllData();
        return { success: true };
    }
}

// Global instance
window.knightleeDB = new KnightleeDatabase();