// Knightlee App - Main Application
document.addEventListener('DOMContentLoaded', async function() {
    // Initialize database
    console.log('Loading Knightlee App...');
    
    // Wait for SQL.js to load
    if (typeof window.SQL === 'undefined') {
        console.error('SQL.js not loaded');
        return;
    }

    // Initialize database
    const success = await window.knightleeDB.init();
    if (!success) {
        alert('Failed to load database');
        return;
    }

    // Initialize map
    initMap();
    
    // Load and display data
    loadDashboardData();
    
    // Setup form handler
    document.getElementById('report-form').addEventListener('submit', handleReport);
});

// Initialize Leaflet map
function initMap() {
    const map = L.map('map').setView([12.9716, 77.5946], 12);
    
    L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
        attribution: '© OpenStreetMap contributors'
    }).addTo(map);
    
    // Store map globally
    window.appMap = map;
    
    // Add incident markers
    updateMap();
}

// Load and display all data
function loadDashboardData() {
    const db = window.knightleeDB;
    
    // Update stats
    document.getElementById('incident-count').textContent = db.getIncidents().length;
    document.getElementById('blackspot-count').textContent = db.getBlackspots().length;
    document.getElementById('high-risk-count').textContent = 
        db.getBlackspots().filter(b => b.severity >= 4).length;
    
    // Display blackspots table
    const blackspotsBody = document.getElementById('blackspots-body');
    blackspotsBody.innerHTML = '';
    
    db.getBlackspots().forEach(spot => {
        const row = document.createElement('tr');
        row.className = `severity-${spot.severity}`;
        row.innerHTML = `
            <td><strong>${spot.name}</strong></td>
            <td>${spot.latitude.toFixed(4)}, ${spot.longitude.toFixed(4)}</td>
            <td>${'⚠'.repeat(spot.severity)} (${spot.severity}/5)</td>
            <td>${spot.description || 'No description'}</td>
        `;
        blackspotsBody.appendChild(row);
    });
    
    // Display incidents table
    const incidentsBody = document.getElementById('incidents-body');
    incidentsBody.innerHTML = '';
    
    db.getIncidents().forEach(incident => {
        const row = document.createElement('tr');
        row.innerHTML = `
            <td>${incident.incident_type.toUpperCase()}</td>
            <td>${incident.description}</td>
            <td>${incident.latitude.toFixed(4)}, ${incident.longitude.toFixed(4)}</td>
            <td id="upvotes-${incident.id}">${incident.upvotes}</td>
            <td><button onclick="upvoteIncident(${incident.id})" class="btn">👍 Upvote</button></td>
        `;
        incidentsBody.appendChild(row);
    });
    
    // Update map markers
    updateMap();
}

// Update map with markers
function updateMap() {
    const map = window.appMap;
    const db = window.knightleeDB;
    
    // Clear existing markers
    if (window.mapMarkers) {
        window.mapMarkers.forEach(marker => marker.remove());
    }
    
    window.mapMarkers = [];
    
    // Add incident markers (red)
    db.getIncidents().forEach(incident => {
        const marker = L.circleMarker([incident.latitude, incident.longitude], {
            color: '#e74c3c',
            fillColor: '#e74c3c',
            fillOpacity: 0.5,
            radius: 8
        }).addTo(map);
        
        marker.bindPopup(`
            <strong>${incident.incident_type.toUpperCase()}</strong><br>
            ${incident.description}<br>
            👍 ${incident.upvotes} upvotes
        `);
        window.mapMarkers.push(marker);
    });
    
    // Add blackspot markers (orange)
    db.getBlackspots().forEach(spot => {
        const marker = L.circleMarker([spot.latitude, spot.longitude], {
            color: '#e67e22',
            fillColor: '#e67e22',
            fillOpacity: 0.7,
            radius: 6 + (spot.severity * 2)
        }).addTo(map);
        
        marker.bindPopup(`
            <strong>${spot.name}</strong><br>
            Severity: ${spot.severity}/5<br>
            ${spot.description || ''}
        `);
        window.mapMarkers.push(marker);
    });
}

// Handle incident reporting
async function handleReport(event) {
    event.preventDefault();
    
    const type = document.getElementById('incident-type').value;
    const description = document.getElementById('incident-desc').value;
    const lat = parseFloat(document.getElementById('incident-lat').value);
    const lng = parseFloat(document.getElementById('incident-lng').value);
    
    if (!type || !description || isNaN(lat) || isNaN(lng)) {
        alert('Please fill all fields correctly');
        return;
    }
    
    const result = window.knightleeDB.addIncident({
        type: type,
        description: description,
        latitude: lat,
        longitude: lng
    });
    
    if (result.success) {
        alert('Incident reported successfully!');
        document.getElementById('report-form').reset();
        loadDashboardData();
    }
}

// Global function for upvoting
window.upvoteIncident = function(id) {
    window.knightleeDB.upvoteIncident(id);
    const upvoteElement = document.getElementById(`upvotes-${id}`);
    if (upvoteElement) {
        upvoteElement.textContent = parseInt(upvoteElement.textContent) + 1;
    }
};

// Export data function
window.exportData = function() {
    const db = window.knightleeDB;
    const data = {
        incidents: db.getIncidents(),
        blackspots: db.getBlackspots(),
        exportTime: new Date().toISOString()
    };
    
    const blob = new Blob([JSON.stringify(data, null, 2)], {type: 'application/json'});
    const url = URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = 'knightlee-data.json';
    a.click();
    URL.revokeObjectURL(url);
};