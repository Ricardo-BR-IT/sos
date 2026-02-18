/**
 * SOS Browser Sense - Discovery Utility
 * Handles Bluetooth, mDNS Probing, and Network Scanning
 */

export const BrowserSense = {
    /**
     * Scan for nearby BLE devices with SOS Service
     */
    async scanBluetooth() {
        if (!navigator.bluetooth) {
            throw new Error('Bluetooth not supported in this browser');
        }

        try {
            const device = await navigator.bluetooth.requestDevice({
                filters: [{ namePrefix: 'SOS-' }],
                optionalServices: ['battery_service', 'device_information']
            });
            return {
                id: device.id,
                name: device.name,
                type: 'BLE',
                status: 'Found'
            };
        } catch (err) {
            console.warn('BLE Discovery cancelled or failed:', err);
            return null;
        }
    },

    /**
     * Probes local network for SOS Hubs
     */
    async probeLocalNetwork(onFound) {
        const commonGateways = [
            '192.168.1.1', '192.168.0.1', '10.0.0.1', '172.16.0.1',
            'localhost', 'sos.local'
        ];

        const ports = [8080, 4000];
        const endpoints = ['/status'];

        for (const host of commonGateways) {
            for (const port of ports) {
                const url = `http://${host}:${port}${endpoints[0]}`;
                this.checkEndpoint(url).then(data => {
                    if (data) {
                        onFound({
                            id: data.id || host,
                            name: `Grid-Node (${host})`,
                            type: 'HUB',
                            url: `http://${host}:${port}`,
                            battery: 100
                        });
                    }
                });
            }
        }
    },

    async checkEndpoint(url) {
        try {
            const controller = new AbortController();
            const id = setTimeout(() => controller.abort(), 2000);
            const response = await fetch(url, {
                mode: 'cors',
                signal: controller.signal
            });
            clearTimeout(id);
            if (response.ok) {
                return await response.json();
            }
        } catch (e) {
            return null;
        }
        return null;
    },

    /**
     * Get Current Geolocation for Radar Placement
     */
    getCurrentPosition() {
        return new Promise((resolve, reject) => {
            if (!navigator.geolocation) {
                reject(new Error('Geolocation not supported'));
                return;
            }
            // Timeout safety
            const timer = setTimeout(() => {
                reject(new Error('Geolocation timeout'));
            }, 5000);

            navigator.geolocation.getCurrentPosition(
                (pos) => {
                    clearTimeout(timer);
                    resolve({
                        lat: pos.coords.latitude,
                        lng: pos.coords.longitude
                    });
                },
                (err) => {
                    clearTimeout(timer);
                    reject(err);
                },
                { enableHighAccuracy: false, timeout: 5000, maximumAge: 60000 }
            );
        });
    },

    /**
     * P2P Signaling Relay Fallback
     * Used when BLE/mDNS is restricted by browser sandbox.
     */
    relayUrl: '/ricardo/sos/api/mesh_relay.php',

    async announcePresence(nodeInfo) {
        try {
            const response = await fetch(this.relayUrl, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify(nodeInfo)
            });
            return await response.json();
        } catch (e) {
            console.error('Relay announcement failed:', e);
            return null;
        }
    },

    async discoverPeers(meshId = null) {
        try {
            const url = meshId ? `${this.relayUrl}?meshId=${encodeURIComponent(meshId)}` : this.relayUrl;
            const response = await fetch(url);
            const data = await response.json();
            return data.nodes || [];
        } catch (e) {
            console.error('Relay discovery failed:', e);
            return [];
        }
    }
};

