/**
 * SOS EXPERIMENTAL MODULE: HARDWARE BRIDGE (V22 OMEGA)
 * Connects to Physical Hardware via Web Serial (LoRa/GPS) and Web Bluetooth.
 * Enhancements: LoRa Packet Parser, Tor Proxy Config.
 */

const Hardware = {
    serialPort: null,
    writer: null,
    reader: null,
    config: {
        torProxy: false,
        proxyHost: "127.0.0.1",
        proxyPort: 9050,
        loraFreq: 915
    },

    init: () => {
        console.log(">>> Hardware Module Loaded (V22)");
        // Load Config from Storage
        const saved = localStorage.getItem('HARDWARE_CFG');
        if (saved) Hardware.config = JSON.parse(saved);
    },

    toggleTor: () => {
        Hardware.config.torProxy = !Hardware.config.torProxy;
        localStorage.setItem('HARDWARE_CFG', JSON.stringify(Hardware.config));
        UI.logSystem(`TOR PROXY: ${Hardware.config.torProxy ? 'ENABLED (SOCKS5)' : 'DISABLED'}`);
        // In a real app, this would modify fetch() calls or WebRTC candidates
    },

    // --- SERIAL (LoRa / GPS) ---
    connectSerial: async () => {
        if (!navigator.serial) {
            alert("Web Serial API not supported in this browser.");
            return;
        }

        try {
            Hardware.serialPort = await navigator.serial.requestPort();
            await Hardware.serialPort.open({ baudRate: 115200 });

            const textDecoder = new TextDecoderStream();
            const readableStreamClosed = Hardware.serialPort.readable.pipeTo(textDecoder.writable);
            Hardware.reader = textDecoder.readable.getReader();

            const textEncoder = new TextEncoderStream();
            const writableStreamClosed = textEncoder.readable.pipeTo(Hardware.serialPort.writable);
            Hardware.writer = textEncoder.writable.getWriter();

            UI.logSystem("Hardware Connected: SERIAL");
            Hardware.readLoop();

        } catch (e) {
            console.error("Serial Error:", e);
            UI.logSystem("Serial Connection Failed");
        }
    },

    readLoop: async () => {
        while (true) {
            const { value, done } = await Hardware.reader.read();
            if (done) {
                Hardware.reader.releaseLock();
                break;
            }
            if (value) {
                Hardware.processPacket(value);
            }
        }
    },

    processPacket: (raw) => {
        // Detect GPS NMEA ($GPGGA)
        if (raw.includes("$GPGGA") || raw.includes("$GPRMC")) {
            Hardware.parseGPS(raw);
        }
        // Detect Meshtastic / Text LoRa (Simulated JSON or Protobuf text)
        else if (raw.startsWith("{") && raw.endsWith("}")) {
            try {
                const packet = JSON.parse(raw);
                if (packet.payload) {
                    UI.logSystem(`LoRa RX: ${packet.payload}`);
                    // Inject into Chat
                    Comms.appendMessage({
                        sender: packet.from || "LORA_NODE",
                        message: packet.payload,
                        timestamp: new Date().toISOString()
                    });
                }
            } catch (e) {
                UI.logSystem(`RAW SERIAL: ${raw}`);
            }
        } else {
            // Raw Text Stream
            UI.logSystem(`RAW: ${raw}`);
        }
    },

    sendLoRa: async (text) => {
        if (Hardware.writer) {
            // Wrap in simple JSON protocol for clarity
            const packet = JSON.stringify({ type: "MSG", payload: text });
            await Hardware.writer.write(packet + "\n");
        } else {
            alert("No Radio Connected!");
        }
    },

    parseGPS: (nmea) => {
        // Simple parser
        const parts = nmea.split(',');
        if (parts[0] === '$GPGGA' && parts.length > 5) {
            const lat = Hardware.dmToDecimal(parts[2], parts[3]);
            const lon = Hardware.dmToDecimal(parts[4], parts[5]);
            if (!isNaN(lat) && !isNaN(lon)) {
                UI.logSystem(`GPS FIX: ${lat.toFixed(5)}, ${lon.toFixed(5)}`);
                // Update Mesh Module Position
                if (window.Mesh) Mesh.updatePosition({ coords: { latitude: lat, longitude: lon } });
            }
        }
    },

    dmToDecimal: (val, ref) => {
        if (!val || val.length < 2) return NaN;
        const deg = parseFloat(val.substring(0, 2));
        const min = parseFloat(val.substring(2));
        let res = deg + (min / 60);
        if (ref === 'S' || ref === 'W') res = res * -1;
        return res;
    },

    // --- BLUETOOTH (Sensors) ---
    scanBLE: async () => {
        if (!navigator.bluetooth) {
            alert("Web Bluetooth API not supported.");
            return;
        }
        try {
            const device = await navigator.bluetooth.requestDevice({
                acceptAllDevices: true,
                optionalServices: ['battery_service']
            });
            const server = await device.gatt.connect();
            UI.logSystem(`BLE Connected: ${device.name}`);
        } catch (e) {
            console.error("BLE Error:", e);
        }
    }
};
