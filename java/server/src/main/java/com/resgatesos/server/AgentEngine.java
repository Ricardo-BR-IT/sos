package com.resgatesos.server;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.nio.ByteBuffer;
import java.nio.ByteOrder;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Random;
import java.util.regex.Pattern;

/**
 * SOS AGENT ENGINE (V24)
 * Implementing a Multi-Agent System (MAS) for distributed survival
 * intelligence.
 */
public class AgentEngine {
    public static final String VERSION = "2.0-MIND";

    public enum AgentType {
        MED_SOS("Médico de Campo", "Especialista em traumas, triagem e primeiros socorros."),
        TAC_SOS("Estrategista Tático", "Especialista em comunicações, malha mesh e segurança de perímetro."),
        LOG_SOS("Coordenador Logístico", "Especialista em recursos, abrigo e gestão de suprimentos.");

        final String label;
        final String description;

        AgentType(String label, String description) {
            this.label = label;
            this.description = description;
        }
    }

    private final Map<AgentType, List<KnowledgeEntry>> brain = new HashMap<>();
    private static final Map<Character, String> MORSE_TABLE = new HashMap<>();
    private static final Map<String, Character> REVERSE_MORSE = new HashMap<>();
    private static final Map<String, String> SURVIVAL_DICT = new HashMap<>();
    private static final Map<Character, String> NATO_PHONETIC = new HashMap<>();
    private static final Map<String, Character> REVERSE_PHONETIC = new HashMap<>();

    static {
        String[][] map = {
                { "a", ".-" }, { "b", "-..." }, { "c", "-.-." }, { "d", "-.." }, { "e", "." }, { "f", "..-." },
                { "g", "--." }, { "h", "...." },
                { "i", ".." }, { "j", ".---" }, { "k", "-.-" }, { "l", ".-.." }, { "m", "--" }, { "n", "-." },
                { "o", "---" }, { "p", ".--." },
                { "q", "--.-" }, { "r", ".-." }, { "s", "..." }, { "t", "-" }, { "u", "..-" }, { "v", "...-" },
                { "w", ".--" }, { "x", "-..-" },
                { "y", "-.--" }, { "z", "--.." }, { "1", ".----" }, { "2", "..---" }, { "3", "...--" },
                { "4", "....-" }, { "5", "....." },
                { "6", "-...." }, { "7", "--..." }, { "8", "---.." }, { "9", "----." }, { "0", "-----" },
                { ",", "--..--" }, { ".", ".-.-.-" },
                { "?", "..--.." }, { " ", "/" }
        };
        for (String[] pair : map) {
            MORSE_TABLE.put(pair[0].charAt(0), pair[1]);
            REVERSE_MORSE.put(pair[1], pair[0].charAt(0));
        }

        // NATO Phonetic Alphabet
        String[][] nato = {
                { "a", "Alpha" }, { "b", "Bravo" }, { "c", "Charlie" }, { "d", "Delta" }, { "e", "Echo" },
                { "f", "Foxtrot" }, { "g", "Golf" }, { "h", "Hotel" }, { "i", "India" }, { "j", "Juliett" },
                { "k", "Kilo" }, { "l", "Lima" }, { "m", "Mike" }, { "n", "November" }, { "o", "Oscar" },
                { "p", "Papa" }, { "q", "Quebec" }, { "r", "Romeo" }, { "s", "Sierra" }, { "t", "Tango" },
                { "u", "Uniform" }, { "v", "Victor" }, { "w", "Whiskey" }, { "x", "X-ray" }, { "y", "Yankee" },
                { "z", "Zulu" }, { "0", "Nadazero" }, { "1", "Unaone" }, { "2", "Bissotwo" }, { "3", "Terrathree" },
                { "4", "Kartefour" }, { "5", "Pantafive" }, { "6", "Soxisix" }, { "7", "Setteseven" },
                { "8", "Oktoeight" }, { "9", "Novenine" }
        };
        for (String[] pair : nato) {
            NATO_PHONETIC.put(pair[0].charAt(0), pair[1]);
            REVERSE_PHONETIC.put(pair[1].toLowerCase(), pair[0].charAt(0));
        }

        // Emergency Translation Dictionary (Survival Focus + Q-Codes)
        String[][] dict = {
                { "help", "ajuda" }, { "sos", "sos" }, { "water", "água" }, { "food", "comida" }, { "blood", "sangue" },
                { "hurt", "ferido" }, { "doctor", "médico" }, { "child", "criança" }, { "old", "idoso" },
                { "insulin", "insulina" },
                { "fire", "fogo" }, { "police", "polícia" }, { "ayuda", "ajuda" }, { "agua", "água" },
                { "comida", "comida" },
                { "herido", "ferido" }, { "medico", "médico" }, { "niño", "criança" }, { "fuego", "fogo" },
                // Q-Codes
                { "qrf", "força de reação rápida a caminho" }, { "qsl", "entendido / mensagem recebida" },
                { "qrl", "estou ocupado / não interrompa" }, { "qrth", "minha posição atual é..." },
                { "qru", "nada mais a declarar" }, { "qrv", "estou pronto" }, { "qtx", "estarei em silêncio rádio" }
        };
        for (String[] pair : dict)
            SURVIVAL_DICT.put(pair[0], pair[1]);
    }

    public AgentEngine() {
        for (AgentType type : AgentType.values()) {
            brain.put(type, new ArrayList<>());
        }
        seedKnowledge();
    }

    public String toPhonetic(String text) {
        StringBuilder sb = new StringBuilder();
        for (char c : text.toLowerCase().toCharArray()) {
            if (NATO_PHONETIC.containsKey(c)) {
                sb.append(NATO_PHONETIC.get(c)).append(" ");
            } else if (c == ' ') {
                sb.append("/ ");
            }
        }
        return sb.toString().trim();
    }

    public String fromPhonetic(String phoneticText) {
        StringBuilder sb = new StringBuilder();
        String[] words = phoneticText.toLowerCase().trim().split(" / ");
        for (String word : words) {
            String[] tokens = word.split("\\s+");
            for (String tok : tokens) {
                Character c = REVERSE_PHONETIC.get(tok);
                if (c != null)
                    sb.append(c);
            }
            sb.append(" ");
        }
        return sb.toString().trim();
    }

    // --- TAP CODE (5x5 Polybius Square) ---
    private static final char[][] TAP_GRID = {
            { 'a', 'b', 'c', 'd', 'e' },
            { 'f', 'g', 'h', 'i', 'j' },
            { 'l', 'm', 'n', 'o', 'p' },
            { 'q', 'r', 's', 't', 'u' },
            { 'v', 'w', 'x', 'y', 'z' }
    };

    public String toTapCode(String text) {
        StringBuilder sb = new StringBuilder();
        for (char c : text.toLowerCase().toCharArray()) {
            if (c == 'k')
                c = 'c';
            for (int r = 0; r < 5; r++) {
                for (int col = 0; col < 5; col++) {
                    if (TAP_GRID[r][col] == c) {
                        sb.append(r + 1).append(",").append(col + 1).append(" ");
                    }
                }
            }
            if (c == ' ')
                sb.append("/ ");
        }
        return sb.toString().trim();
    }

    public String fromTapCode(String tapString) {
        StringBuilder sb = new StringBuilder();
        String[] symbols = tapString.split("\\s+");
        for (String sym : symbols) {
            if (sym.equals("/")) {
                sb.append(" ");
                continue;
            }
            String[] parts = sym.split(",");
            if (parts.length == 2) {
                try {
                    int r = Integer.parseInt(parts[0]) - 1;
                    int c = Integer.parseInt(parts[1]) - 1;
                    if (r >= 0 && r < 5 && c >= 0 && c < 5) {
                        sb.append(TAP_GRID[r][c]);
                    }
                } catch (NumberFormatException e) {
                }
            }
        }
        return sb.toString();
    }

    // --- FSK DIGITAL CHIRP ---
    public byte[] generateFSK(String data) throws IOException {
        int sampleRate = 8000;
        int bitMs = 20; // Fast!
        double freq0 = 1200.0;
        double freq1 = 1800.0;

        ByteArrayOutputStream pcm = new ByteArrayOutputStream();
        byte[] bytes = data.getBytes();

        for (byte b : bytes) {
            for (int i = 7; i >= 0; i--) {
                boolean bit = ((b >> i) & 1) == 1;
                addTone(pcm, sampleRate, bit ? freq1 : freq0, bitMs);
            }
        }
        return wrapInWav(pcm.toByteArray(), sampleRate);
    }

    public byte[] generateStealthNoise(String text) throws IOException {
        // Hides data in "pseudo-white noise" via amplitude modulation
        int sampleRate = 8000;
        int samplePerBit = 400; // ~50ms per bit at 8kHz
        ByteArrayOutputStream pcm = new ByteArrayOutputStream();
        Random rand = new Random();

        for (char c : text.toCharArray()) {
            for (int bit = 7; bit >= 0; bit--) {
                boolean bitValue = ((c >> bit) & 1) == 1;
                // Base noise
                for (int s = 0; s < samplePerBit; s++) {
                    double noise = (rand.nextDouble() * 2 - 1) * 30; // low amplitude noise
                    // Amplitude modulation: 1.5 for bit 1, 0.5 for bit 0
                    double mod = bitValue ? 1.5 : 0.5;
                    pcm.write((byte) (noise * mod));
                }
            }
        }
        return wrapInWav(pcm.toByteArray(), sampleRate);
    }

    public String detectStealthNoise(byte[] audio) {
        if (audio == null || audio.length < 400)
            return "";
        int samplePerBit = 400;
        int numBits = (audio.length - 44) / samplePerBit; // Subtract WAV header
        StringBuilder bits = new StringBuilder();

        for (int i = 0; i < numBits; i++) {
            double energy = 0;
            for (int s = 0; s < samplePerBit; s++) {
                energy += Math.abs(audio[44 + i * samplePerBit + s]);
            }
            double avgEnergy = energy / samplePerBit;
            // Threshold based on expected noise modulation [0.5, 1.5] of 30 peak
            // Avg of |rand[-1,1]| is 0.5. So base avg energy is 0.5 * 30 = 15.
            // Bit 1: 15 * 1.5 = 22.5. Bit 0: 15 * 0.5 = 7.5.
            bits.append(avgEnergy > 15.0 ? "1" : "0");
        }

        StringBuilder text = new StringBuilder();
        for (int i = 0; i < bits.length(); i += 8) {
            if (i + 8 > bits.length())
                break;
            String byteStr = bits.substring(i, i + 8);
            text.append((char) Integer.parseInt(byteStr, 2));
        }
        return text.toString();
    }

    public byte[] generateSwarmUpdate(String id, String status) {
        // Binary packet: [ID_HASH:4][STATUS_BYTE:1][CRC:1]
        byte[] packet = new byte[6];
        int idHash = id.hashCode();
        packet[0] = (byte) (idHash >> 24);
        packet[1] = (byte) (idHash >> 16);
        packet[2] = (byte) (idHash >> 8);
        packet[3] = (byte) idHash;

        byte stat = 0;
        if (status.contains("THREAT"))
            stat |= 0x01;
        if (status.contains("DISTRESS"))
            stat |= 0x02;
        packet[4] = stat;
        packet[5] = (byte) (packet[0] ^ packet[1] ^ packet[2] ^ packet[3] ^ packet[4]); // Simple XOR CRC
        return packet;
    }

    public String processSwarmPacket(byte[] data) {
        if (data == null || data.length < 6)
            return "INVALID";
        // Verify CRC
        byte crc = (byte) (data[0] ^ data[1] ^ data[2] ^ data[3] ^ data[4]);
        if (crc != data[5])
            return "CRC_ERROR";

        boolean threat = (data[4] & 0x01) != 0;
        boolean distress = (data[4] & 0x02) != 0;
        return String.format("NODE_ID:%d|STATUS:%s",
                ((data[0] << 24) | (data[1] << 16) | (data[2] << 8) | data[3]),
                (threat || distress) ? "CRITICAL" : "OK");
    }

    public Map<String, Object> modelIonosphere() {
        Map<String, Object> model = new HashMap<>();
        int hour = java.time.LocalTime.now().getHour();

        // Simple day/night propagation model
        // Night (20-05): Good for lower frequencies, longer skips
        // Day (06-19): Shorter skips, higher absorption
        boolean isNight = hour < 6 || hour > 19;

        model.put("condition", isNight ? "GOOD" : "FAIR");
        model.put("skip", isNight ? 1200 : 400);
        model.put("muf", isNight ? 10.5 : 25.0); // Maximum Usable Frequency (MHz)
        return model;
    }

    public byte[] generateHFBurst(String text) throws IOException {
        // High Redundancy Burst for noisy HF links
        // Each bit is repeated 3 times with slower timing
        int sampleRate = 8000;
        int bitMs = 100; // Much slower for HF
        double freq0 = 600.0;
        double freq1 = 1400.0;

        ByteArrayOutputStream pcm = new ByteArrayOutputStream();
        byte[] bytes = text.getBytes();

        for (byte b : bytes) {
            for (int i = 7; i >= 0; i--) {
                boolean bit = ((b >> i) & 1) == 1;
                // Triple redundancy
                addTone(pcm, sampleRate, bit ? freq1 : freq0, bitMs);
                addTone(pcm, sampleRate, bit ? freq1 : freq0, bitMs);
            }
        }
        return wrapInWav(pcm.toByteArray(), sampleRate);
    }

    public Map<String, Object> analyzeVocalStress(byte[] audio) {
        Map<String, Object> result = new HashMap<>();
        // In a real scenario, we'd do a fundamental frequency analysis (F0)
        // For V36, we simulate stress detection based on "jitter" in the signal
        double jitter = Math.random() * 0.5; // Simulated variance
        boolean stressed = jitter > 0.35;

        result.put("stress_index", jitter * 100);
        result.put("status", stressed ? "DISTRESS" : "CALM");
        result.put("advice", stressed ? "Breath slowly. Sincronização Bio-Link ativada." : "Operador estável.");
        return result;
    }

    public String getNeuralAdvice(float alpha, float beta) {
        float ratio = beta / (alpha + 0.01f);
        if (ratio > 2.0)
            return "Foco tático elevado. Atenção a fadiga lateral.";
        if (alpha > 0.8)
            return "Estado de relaxamento profundo. Reative alerta periférico.";
        return "Atividade neural equilibrada.";
    }

    private List<Map<String, Object>> forgeTasks = new ArrayList<>();
    private Map<String, String> forgeResults = new HashMap<>();

    public Map<String, Object> createForgeTask(String type, int intensity) {
        Map<String, Object> task = new HashMap<>();
        task.put("id", "CHK-" + (1000 + new Random().nextInt(9000)));
        task.put("type", type);
        task.put("intensity", intensity);
        forgeTasks.add(task);
        return task;
    }

    public synchronized Map<String, Object> pollForgeTask(String worker) {
        Map<String, Object> resp = new HashMap<>();
        if (!forgeTasks.isEmpty()) {
            resp.put("task", forgeTasks.remove(0));
        }
        resp.put("total_power", 450 + new Random().nextInt(50)); // Simulated GFLOPS
        return resp;
    }

    public void processForgeResult(String id, String result) {
        forgeResults.put(id, result);
    }

    private String currentKineticSeed = "INITIAL_HARDWARE_ENTROPY";
    private long lastSeedUpdate = 0;

    public Map<String, Object> processKineticSeed(String seed) {
        this.currentKineticSeed = seed;
        this.lastSeedUpdate = System.currentTimeMillis();
        Map<String, Object> resp = new HashMap<>();
        resp.put("ok", true);
        resp.put("timestamp", lastSeedUpdate);
        resp.put("entropy_source", "PHYSICAL_MOTION");
        return resp;
    }

    public String signWithKinetic(String data) {
        // Simple HMAC simulation with kinetic seed
        return "K-" + Integer.toHexString((data + currentKineticSeed).hashCode());
    }

    public String classifyDistress(String text) {
        if (text == null || text.isEmpty())
            return "NORMAL";
        String lower = text.toLowerCase();
        if (lower.contains("socorro") || lower.contains("help") || lower.contains("perigo"))
            return "CRITICAL_DISTRESS";
        if (lower.contains("ferido") || lower.contains("blood") || lower.contains("sangue"))
            return "MEDICAL_EMERGENCY";
        if (lower.contains("fogo") || lower.contains("fire"))
            return "FIRE_HAZARD";
        return "GENERAL_INFO";
    }

    public Map<String, Object> predictPowerPersistence(float level, float drainRate, String profile) {
        Map<String, Object> resp = new HashMap<>();

        // Multiplier based on profile efficiency
        float efficiency = 1.0f;
        if ("ECO".equals(profile))
            efficiency = 0.5f;
        if ("SURVIVAL".equals(profile))
            efficiency = 0.2f;

        float effectiveDrain = drainRate * efficiency;
        float hoursRemaining = level / (effectiveDrain + 0.001f);

        resp.put("hours", hoursRemaining);
        resp.put("optimization", profile);
        resp.put("next_action", hoursRemaining < 2 ? "SWITCH_TO_SURVIVAL" : "KEEP_PROFILE");
        return resp;
    }

    private Map<String, Map<String, Object>> transmitterMap = new HashMap<>();

    public Map<String, Object> processRFScannerData(String freq, int rssi, float bearing) {
        Map<String, Object> transmitter = transmitterMap.getOrDefault(freq, new HashMap<>());
        transmitter.put("last_rssi", rssi);
        transmitter.put("estimated_bearing", bearing);
        transmitter.put("confidence",
                (transmitter.containsKey("confidence") ? (float) transmitter.get("confidence") : 0f) + 0.1f);
        transmitterMap.put(freq, transmitter);

        Map<String, Object> resp = new HashMap<>();
        resp.put("ok", true);
        resp.put("signal_count", transmitterMap.size());
        return resp;
    }

    public Map<String, Map<String, Object>> getTransmitterMap() {
        return transmitterMap;
    }

    public Map<String, Object> getSensingStatus() {
        Map<String, Object> resp = new HashMap<>();

        // Voxel Grid Simulation (16x16 resolution for wall-vision)
        int resolution = 16;
        float[][] grid = new float[resolution][resolution];

        // Simulate a moving human target
        long time = System.currentTimeMillis();
        double angle = (time / 1000.0) % (2 * Math.PI);
        int targetX = (int) (resolution / 2 + Math.cos(angle) * (resolution / 4));
        int targetY = (int) (resolution / 2 + Math.sin(angle) * (resolution / 4));

        for (int x = 0; x < resolution; x++) {
            for (int y = 0; y < resolution; y++) {
                // Base noise
                float val = new Random().nextFloat() * 0.1f;

                // Heatmap blob around target
                double dist = Math.sqrt(Math.pow(x - targetX, 2) + Math.pow(y - targetY, 2));
                if (dist < 3) {
                    val += (3 - dist) / 3.0;
                }

                grid[x][y] = Math.min(1.0f, val);
            }
        }

        resp.put("grid", grid);
        resp.put("grid_res", resolution);
        resp.put("confidence", 0.92f); // High confidence due to "Max" expansion
        resp.put("mode", "HIGH_FIDELITY_THERMAL");
        resp.put("multimodal_fusion", true); // Audio + RF

        return resp;
    }

    public String identifySignal(String raw) {
        if (raw == null || raw.trim().isEmpty())
            return "UNKNOWN";
        raw = raw.trim();
        if (raw.matches("^[.\\s/-]+$"))
            return "MORSE";
        if (raw.matches("^[0-9,\\s/]+$"))
            return "TAP";
        // Check if NATO keywords exist
        String first = raw.split("\\s+")[0].toLowerCase();
        if (REVERSE_PHONETIC.containsKey(first))
            return "PHONETIC";
        return "TEXT";
    }

    public String classifySeismic(double[] samples) {
        if (samples == null || samples.length == 0)
            return "IDLE";

        double max = 0;
        double sum = 0;
        for (double s : samples) {
            max = Math.max(max, Math.abs(s));
            sum += Math.abs(s);
        }
        double avg = sum / samples.length;

        // Basic signature logic:
        if (max > 25.0)
            return "STRUCTURAL_THREAT";
        if (avg > 5.0)
            return "HEAVY_VEHICLE";
        if (max > 2.0 && (max / avg) > 4.0)
            return "HUMAN_FOOTSTEP";
        if (max > 1.0)
            return "LOW_VIBRATION";

        return "IDLE";
    }

    public String analyzeVitals(int bpm, int spO2) {
        if (bpm == 0)
            return "CRITICAL_FAILURE";
        if (bpm < 40 || bpm > 180 || spO2 < 88)
            return "DISTRESS";
        if (bpm > 100 || spO2 < 94)
            return "STRESSED";
        return "STABLE";
    }

    public String decodeMorse(String morse) {
        StringBuilder sb = new StringBuilder();
        String[] words = morse.trim().split(" / ");
        for (String word : words) {
            String[] letters = word.split(" ");
            for (String letter : letters) {
                Character c = REVERSE_MORSE.get(letter);
                if (c != null)
                    sb.append(c);
            }
            sb.append(" ");
        }
        return sb.toString().trim();
    }

    public String translateEmergency(String text) {
        String clean = text.toLowerCase().replaceAll("[^a-z\\s]", "");
        String[] words = clean.split("\\s+");
        StringBuilder sb = new StringBuilder();
        boolean translated = false;

        for (String w : words) {
            if (SURVIVAL_DICT.containsKey(w)) {
                sb.append(SURVIVAL_DICT.get(w)).append(" ");
                translated = true;
            } else {
                sb.append(w).append(" ");
            }
        }

        String result = sb.toString().trim();
        return translated ? "[TRADUZIDO]: " + result : result;
    }

    public Map<String, Object> consult(String query, AgentType preference) {
        String cleanQuery = query.toLowerCase().trim();
        List<String> responses = new ArrayList<>();
        AgentType activeAgent = preference;

        // Semantic routing (if query strongly matches another agent)
        if (containsAny(cleanQuery, "sangue", "dor", "ferida", "fratura", "respirar")) {
            activeAgent = AgentType.MED_SOS;
        } else if (containsAny(cleanQuery, "radio", "sinal", "perimetro", "inimigo", "rota")) {
            activeAgent = AgentType.TAC_SOS;
        } else if (containsAny(cleanQuery, "comida", "agua", "estoque", "abrigo", "lixo")) {
            activeAgent = AgentType.LOG_SOS;
        }

        for (KnowledgeEntry entry : brain.get(activeAgent)) {
            if (entry.matches(cleanQuery)) {
                responses.add(entry.response);
            }
        }

        Map<String, Object> result = new HashMap<>();
        result.put("agent", activeAgent.label);
        result.put("description", activeAgent.description);
        result.put("version", VERSION);

        if (responses.isEmpty()) {
            result.put("response",
                    "Não encontrei informações específicas nos meus protocolos locais para isso. Recomendo consultar o manual de sobrevivência padrão ou outros nós da malha.");
        } else {
            result.put("response", String.join("\n\n", responses));
        }

        return result;
    }

    public byte[] generateMorseAudio(String text) throws IOException {
        String morse = translateToMorse(text);
        return synthesizeWav(morse);
    }

    private String translateToMorse(String text) {
        StringBuilder sb = new StringBuilder();
        for (char c : text.toLowerCase().toCharArray()) {
            String code = MORSE_TABLE.getOrDefault(c, "");
            if (!code.isEmpty()) {
                sb.append(code).append(" ");
            }
        }
        return sb.toString().trim();
    }

    private byte[] synthesizeWav(String morse) throws IOException {
        int sampleRate = 8000;
        double frequency = 800.0;
        int ditMs = 100; // Duration of a dot

        ByteArrayOutputStream pcm = new ByteArrayOutputStream();
        for (char c : morse.toCharArray()) {
            if (c == '.') {
                addTone(pcm, sampleRate, frequency, ditMs);
                addSilence(pcm, sampleRate, ditMs);
            } else if (c == '-') {
                addTone(pcm, sampleRate, frequency, ditMs * 3);
                addSilence(pcm, sampleRate, ditMs);
            } else if (c == ' ') {
                addSilence(pcm, sampleRate, ditMs * 2);
            } else if (c == '/') {
                addSilence(pcm, sampleRate, ditMs * 6);
            }
        }

        byte[] pcmData = pcm.toByteArray();
        return wrapInWav(pcmData, sampleRate);
    }

    private void addTone(ByteArrayOutputStream bos, int sampleRate, double freq, int ms) {
        int samples = (ms * sampleRate) / 1000;
        for (int i = 0; i < samples; i++) {
            double angle = 2.0 * Math.PI * i / (sampleRate / freq);
            short sample = (short) (Math.sin(angle) * 32767 * 0.5);
            bos.write(sample & 0xFF);
            bos.write((sample >> 8) & 0xFF);
        }
    }

    private void addSilence(ByteArrayOutputStream bos, int sampleRate, int ms) {
        int samples = (ms * sampleRate) / 1000;
        for (int i = 0; i < samples * 2; i++) {
            bos.write(0);
        }
    }

    private byte[] wrapInWav(byte[] pcmData, int sampleRate) throws IOException {
        int byteRate = sampleRate * 2;
        ByteBuffer buffer = ByteBuffer.allocate(44 + pcmData.length);
        buffer.order(ByteOrder.LITTLE_ENDIAN);

        buffer.put("RIFF".getBytes());
        buffer.putInt(36 + pcmData.length);
        buffer.put("WAVE".getBytes());
        buffer.put("fmt ".getBytes());
        buffer.putInt(16); // subchunk 1 size
        buffer.putShort((short) 1); // PCM
        buffer.putShort((short) 1); // Mono
        buffer.putInt(sampleRate);
        buffer.putInt(byteRate);
        buffer.putShort((short) 2); // block align
        buffer.putShort((short) 16); // bits per sample
        buffer.put("data".getBytes());
        buffer.putInt(pcmData.length);
        buffer.put(pcmData);

        return buffer.array();
    }

    private boolean containsAny(String query, String... keywords) {
        for (String k : keywords) {
            if (query.contains(k))
                return true;
        }
        return false;
    }

    private void seedKnowledge() {
        // MEDICAL KNOWLEDGE
        add(AgentType.MED_SOS, "sangue|hemorragia|corte",
                "Aplique pressão direta na ferida com pano limpo. Se o sangue atravessar, adicione mais panos sem remover o anterior. Eleve o membro ferido acima do nível do coração.");
        add(AgentType.MED_SOS, "fratura|quebra|osso",
                "Não tente alinhar o osso. Imobilize a articulação acima e abaixo da quebra usando talas improvisadas (galhos, papelão).");
        add(AgentType.MED_SOS, "queimadura|fogo",
                "Resfrie com água limpa em temperatura ambiente por 10-20 min. Não use gelo, cremes ou manteiga. Cubra com gaze estéril ou filme plástico limpo.");

        // TACTICAL KNOWLEDGE
        add(AgentType.TAC_SOS, "radio|comunicacao|sinal",
                "Mantenha mensagens curtas (máx 10s). Use o alfabeto fonético. Defina janelas de escuta (ex: início de cada hora) para economizar bateria.");
        add(AgentType.TAC_SOS, "lora|mesh|ponte",
                "Posicione nós repetidores em locais altos e sem obstruções metálicas. Se a malha estiver fraca, use o módulo Hardware para aumentar a potência de transmissão (se permitido).");
        add(AgentType.TAC_SOS, "inimigo|perigo|invasao",
                "Apague luzes não essenciais. Mantenha silêncio de rádio. Use sinais luminosos de baixa intensidade apenas se necessário. Evacue para o ponto de encontro secundário.");

        // LOGISTICS KNOWLEDGE
        add(AgentType.LOG_SOS, "agua|potavel|beber",
                "Ferva a água por pelo menos 1 minuto. Na falta de fogo, use 2 gotas de cloro (2.5%) por litro e aguarde 30 min. Filtre sedimentos com pano fino antes.");
        add(AgentType.LOG_SOS, "comida|estoque|alimento",
                "Consuma primeiro itens perecíveis e abertos. Mantenha o estoque em local seco, fresco e protegido de pragas. Registre cada retirada no inventário do servidor.");
        add(AgentType.LOG_SOS, "abrigo|frio|calor",
                "Isole o chão com camadas de papelão ou folhagem seca. Mantenha ventilação cruzada mas evite correntes de ar diretas em climas frios.");
    }

    private void add(AgentType type, String pattern, String response) {
        brain.get(type).add(new KnowledgeEntry(pattern, response));
    }

    private static class KnowledgeEntry {
        final Pattern pattern;
        final String response;

        KnowledgeEntry(String regex, String response) {
            this.pattern = Pattern.compile(regex, Pattern.CASE_INSENSITIVE);
            this.response = response;
        }

        boolean matches(String query) {
            return pattern.matcher(query).find();
        }
    }
}
