<?php
// API: PROXY ALERTS (V8)
// Fetches external data or returns simulation

header('Content-Type: application/json');

// SIMULATION MODE (Set to false when real APIs are connected)
$SIMULATION = true;

if ($SIMULATION) {
    // Return Mock Data for Demo
    echo json_encode([
        'status' => 'OK',
        'alerts' => [
            [
                'type' => 'SEISMIC',
                'title' => 'M 5.2 Earthquake',
                'location' => 'Coast of Chile',
                'lat' => -30.5,
                'lng' => -71.5,
                'level' => 'WARNING'
            ],
            [
                'type' => 'WEATHER',
                'title' => 'Severe Storm Front',
                'location' => 'South Brazil',
                'lat' => -29.0,
                'lng' => -50.0,
                'level' => 'CRITICAL'
            ],
            [
                'type' => 'SOLAR',
                'title' => 'K-Index 6 (Geomagnetic Storm)',
                'location' => 'Global',
                'lat' => 0,
                'lng' => 0,
                'level' => 'WATCH'
            ]
        ]
    ]);
} else {
    // Real Fetch Logic (USGS, etc)
    // TBD in future update
}
?>
