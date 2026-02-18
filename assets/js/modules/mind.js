/**
 * SOS MODULE: MIND (V24)
 * Distributed Multi-Agent Tactical Consultation.
 */

const Mind = {
    activeAgent: 'TAC_SOS',
    agents: [],

    init: async () => {
        console.log(">>> Mind Module Loaded");
        // Optional: Load agent catalog from server
        // Mind.loadCatalog();
        if (window.SwarmMesh) SwarmMesh.init();
        if (window.SkywaveLink) SkywaveLink.init();
        if (window.MindLink) MindLink.init();
        if (window.MeshForge) MeshForge.init();
        if (window.KineticSecurity) KineticSecurity.init();
        if (window.PowerAutonomy) PowerAutonomy.init();
        if (window.RFCompass) RFCompass.init();
        if (window.WiFiSensing) WiFiSensing.init();
    },

    isVisionActive: false,
    toggleVision: () => {
        const btn = document.getElementById('mind-vision-btn');
        if (Mind.isVisionActive) {
            WiFiSensing.stop();
            Mind.isVisionActive = false;
            btn.style.background = "";
            Mind.displayResponse({ agent: "SISTEMA", response: "Visão Wi-Fi (CSI) Desativada." });
        } else {
            WiFiSensing.start();
            Mind.isVisionActive = true;
            btn.style.background = "var(--neon-green)";
            btn.style.color = "#000";
            Mind.displayResponse({
                agent: "SISTEMA",
                response: "VISÃO ATIVA. Analisando ondas Wi-Fi para detecção de presença através de obstáculos."
            });
        }
    },

    isRFActive: false,
    toggleRFCompass: () => {
        const btn = document.getElementById('mind-rf-btn');
        if (Mind.isRFActive) {
            RFCompass.stop();
            Mind.isRFActive = false;
            btn.style.background = "";
            Mind.displayResponse({ agent: "SISTEMA", response: "Scanner RF Multispectral Desativado." });
        } else {
            RFCompass.start();
            Mind.isRFActive = true;
            btn.style.background = "var(--neon-cyan)";
            btn.style.color = "#000";
            Mind.displayResponse({
                agent: "SISTEMA",
                response: "BÚSSOLA RF ATIVA. Escaneando AM/FM/TV/CELL para localização de fontes."
            });
        }
    },

    isAutonomyActive: false,
    toggleAutonomy: () => {
        const btn = document.getElementById('mind-pwr-btn');
        if (Mind.isAutonomyActive) {
            PowerAutonomy.stop();
            Mind.isAutonomyActive = false;
            btn.style.background = "";
            Mind.displayResponse({ agent: "SISTEMA", response: "Gestão de Energia Autônoma Desativada." });
        } else {
            PowerAutonomy.start();
            Mind.isAutonomyActive = true;
            btn.style.background = "var(--neon-green)";
            btn.style.color = "#000";
            Mind.displayResponse({
                agent: "SISTEMA",
                response: "AUTONOMIA ATIVA. A IA agora gerencia sua bateria para máxima sobrevivência."
            });
        }
    },

    isKineticActive: false,
    toggleKinetic: () => {
        const btn = document.getElementById('mind-kinetic-btn');
        if (Mind.isKineticActive) {
            KineticSecurity.stop();
            Mind.isKineticActive = false;
            btn.style.background = "";
            Mind.displayResponse({ agent: "SISTEMA", response: "Entropia Cinética Desativada. Usando semente padrão." });
        } else {
            KineticSecurity.start();
            Mind.isKineticActive = true;
            btn.style.background = "var(--neon-green)";
            btn.style.color = "#000";
            Mind.displayResponse({
                agent: "SISTEMA",
                response: "SEGURANÇA CINÉTICA ATIVA. Mova o dispositivo para aumentar a entropia."
            });
        }
    },

    isForgeActive: false,
    toggleForge: () => {
        const btn = document.getElementById('mind-forge-btn');
        if (Mind.isForgeActive) {
            MeshForge.stop();
            Mind.isForgeActive = false;
            btn.style.background = "";
            Mind.displayResponse({ agent: "SISTEMA", response: "Desconectado do cluster Mesh Forge." });
        } else {
            MeshForge.start();
            Mind.isForgeActive = true;
            btn.style.background = "var(--neon-green)";
            btn.style.color = "#000";
            Mind.displayResponse({
                agent: "SISTEMA",
                response: "Conectado ao CLUSTER FORGE. Cedendo poder de processamento ocioso."
            });
        }
    },

    isLinkActive: false,
    toggleLink: () => {
        const btn = document.getElementById('mind-link-btn');
        if (Mind.isLinkActive) {
            MindLink.stop();
            Mind.isLinkActive = false;
            btn.style.background = "";
            Mind.displayResponse({ agent: "SISTEMA", response: "Mind-Link (Interface Neural/Trauma) Offline." });
        } else {
            MindLink.startAudio();
            Mind.isLinkActive = true;
            btn.style.background = "var(--neon-green)";
            btn.style.color = "#000";
            Mind.displayResponse({
                agent: "SISTEMA",
                response: "Mind-Link ATIVO. Analisando padrões de estresse acústico..."
            });
        }
    },

    isOTHActive: false,
    toggleOTH: () => {
        const btn = document.getElementById('mind-oth-btn');
        if (Mind.isOTHActive) {
            SkywaveLink.stop();
            Mind.isOTHActive = false;
            btn.style.background = "";
            Mind.displayResponse({ agent: "SISTEMA", response: "Modo Ultra-Longo-Alcance (OTH) Desativado." });
        } else {
            SkywaveLink.start();
            Mind.isOTHActive = true;
            btn.style.background = "var(--neon-green)";
            btn.style.color = "#000";
            Mind.displayResponse({
                agent: "SISTEMA",
                response: "Modo OTH ATIVO. Simulando propagação ionosférica para bases distantes."
            });
        }
    },

    isSwarmActive: false,
    toggleSwarm: () => {
        const btn = document.getElementById('mind-swarm-btn');
        const list = document.getElementById('swarm-list');

        if (Mind.isSwarmActive) {
            SwarmMesh.stop();
            Mind.isSwarmActive = false;
            btn.style.background = "";
            list.style.display = 'none';
            Mind.displayResponse({ agent: "SISTEMA", response: "Sincronização de Enxame OFF." });
        } else {
            SwarmMesh.start();
            Mind.isSwarmActive = true;
            btn.style.background = "var(--neon-cyan)";
            btn.style.color = "#000";
            list.style.display = 'block';
            Mind.displayResponse({ agent: "SISTEMA", response: "Sincronização de Enxame ATIVA. Monitorando nós próximos..." });
        }
    },

    consult: async (query) => {
        const overlay = document.getElementById('mind-overlay');
        if (overlay) overlay.style.display = 'flex';

        try {
            const resp = await fetch(`api/mind.php?q=${encodeURIComponent(query)}&agent=${Mind.activeAgent}`);
            const data = await resp.json();

            Mind.displayResponse(data);
        } catch (e) {
            console.error("Mind Consultation Failed", e);
            Mind.displayResponse({
                agent: "Erro de Conexão",
                response: "Falha ao consultar a Mente da Malha. Verifique a conexão com o servidor local."
            });
        } finally {
            if (overlay) overlay.style.display = 'none';
        }
    },

    displayResponse: (data) => {
        const chatBox = document.getElementById('mind-chat-log');
        if (!chatBox) return;

        const entry = document.createElement('div');
        entry.className = 'mind-entry';
        entry.innerHTML = `
            <div class="mind-agent-name">[${data.agent}]</div>
            <div class="mind-agent-text">${data.response}</div>
            <hr class="dim">
        `;

        chatBox.appendChild(entry);
        chatBox.scrollTop = chatBox.scrollHeight;
    },

    generateSignal: async () => {
        const input = document.getElementById('mind-input');
        if (!input || !input.value.trim()) {
            alert("Digite a mensagem para converter em sinal.");
            return;
        }

        const query = input.value;
        const url = `api/signal.php?q=${encodeURIComponent(query)}`;

        // Play audio directly
        const audio = new Audio(url);
        audio.play().catch(e => {
            console.error("Audio Playback Failed", e);
            // Fallback: Download the file
            const link = document.createElement('a');
            link.href = url;
            link.download = 'sos_signal.wav';
            link.click();
        });

        Mind.displayResponse({
            agent: "SINALIZADOR",
            response: `Sinal Morse gerador para: "${query}". Reproduzindo áudio...`
        });
    },

    toggleListen: async () => {
        const btn = document.getElementById('mind-listen-btn');
        if (AudioIntelligence.isListening) {
            AudioIntelligence.stop();
            btn.innerText = "🎙️ LISTEN";
            btn.style.background = "";
            Mind.displayResponse({ agent: "SISTEMA", response: "Modo de escuta desativado." });
        } else {
            btn.innerText = "🔴 LISTENING...";
            btn.style.background = "var(--neon-red)";
            Mind.displayResponse({ agent: "SISTEMA", response: "Escuta ativada. Direcione o microfone para a fonte sonora." });

            await AudioIntelligence.start(async (pulses) => {
                const label = document.getElementById('mind-active-label');
                if (label) label.innerText = `Pulsos: ${pulses}`;

                // Real-time decoding every few pulses or after a pause
                if (pulses.length % 5 === 0) {
                    try {
                        const resp = await fetch(`api/decode.php?m=${encodeURIComponent(pulses)}`);
                        const data = await resp.json();
                        const chatLog = document.getElementById('mind-chat-log');
                        // Update current line instead of appending (Advanced UX)
                        Mind.updateLiveTranscription(data.translated);
                    } catch (e) { }
                }
            });
        }
    },

    updateLiveTranscription: (text) => {
        let live = document.getElementById('mind-live-line');
        if (!live) {
            live = document.createElement('div');
            live.id = 'mind-live-line';
            live.style.color = 'var(--neon-cyan)';
            live.style.borderLeft = '2px solid var(--neon-cyan)';
            live.style.paddingLeft = '5px';
            document.getElementById('mind-chat-log').appendChild(live);
        }
        live.innerText = `Transcrição: ${text}`;
    },

    generatePhonetic: async () => {
        const input = document.getElementById('mind-input');
        if (!input || !input.value.trim()) {
            alert("Digite a mensagem para converter em fonético.");
            return;
        }

        const query = input.value;
        const resp = await fetch(`api/phonetic.php?q=${encodeURIComponent(query)}`);
        const data = await resp.json();

        if (data.phonetic) {
            Mind.displayResponse({
                agent: "FONÉTICO",
                response: `NATO Alpha-Zulu: ${data.phonetic}. Iniciando síntese de voz...`
            });

            // Browser Speech Synthesis
            const msg = new SpeechSynthesisUtterance(data.phonetic);
            msg.lang = 'en-US'; // Phonetic is technically English
            msg.rate = 0.8;
            window.speechSynthesis.speak(msg);
        }
    },

    isARActive: false,
    toggleAR: async () => {
        const modal = document.getElementById('mind-modal');
        const arOverlay = document.getElementById('ar-overlay');
        const btn = document.getElementById('mind-ar-btn');

        if (Mind.isARActive) {
            TacticalAR.stop();
            Mind.isARActive = false;
            arOverlay.style.display = 'none';
            modal.style.opacity = '1';
            btn.style.background = "";
            Mind.displayResponse({ agent: "SISTEMA", response: "Modo AR desativado." });
        } else {
            const success = await TacticalAR.start();
            if (success) {
                Mind.isARActive = true;
                arOverlay.style.display = 'block';
                modal.style.opacity = '0.3'; // Make modal transparent to see AR
                btn.style.background = "var(--neon-cyan)";
                btn.style.color = "#000";
                Mind.displayResponse({ agent: "SISTEMA", response: "HUD AR Ativado. Aponte a câmera para o horizonte." });
            } else {
                alert("Falha ao acessar câmera para AR.");
            }
        }
    },

    isSeismicActive: false,
    toggleSeismic: () => {
        const btn = document.getElementById('mind-seismic-btn');
        if (Mind.isSeismicActive) {
            if (window.SeismicIntel) SeismicIntel.stop();
            Mind.isSeismicActive = false;
            btn.style.background = "";
            Mind.displayResponse({ agent: "SISTEMA", response: "Monitoramento sísmico desativado." });
        } else {
            if (window.SeismicIntel) {
                SeismicIntel.start((data) => {
                    Mind.updateLiveTranscription(`SÍSMICO: ${data.status} [${data.translated}]`);
                });
            }
            Mind.isSeismicActive = true;
            btn.style.background = "var(--neon-cyan)";
            btn.style.color = "#000";
            Mind.displayResponse({
                agent: "SISTEMA",
                response: "Sensor sísmico armado. Coloque o dispositivo em uma superfície sólida."
            });
        }
    },

    isBioActive: false,
    toggleBio: async () => {
        const btn = document.getElementById('mind-bio-btn');
        if (Mind.isBioActive) {
            if (window.BioSync) BioSync.stop();
            Mind.isBioActive = false;
            btn.style.background = "";
            Mind.displayResponse({ agent: "SISTEMA", response: "Monitoramento de sinais vitais desativado." });
        } else {
            const paired = window.BioSync ? await BioSync.pair() : false;
            if (window.BioSync) {
                BioSync.start((data, bpm) => {
                    const label = document.getElementById('mind-vitals-label');
                    if (label) label.innerText = `❤️ ${bpm} BPM | STATUS: ${data.status}`;
                    if (data.status === 'DISTRESS' || data.status === 'CRITICAL_FAILURE') {
                        Mind.updateLiveTranscription(`ALERTA BIOLÓGICO: ${data.translated}`);
                    }
                });
            }
            Mind.isBioActive = true;
            btn.style.background = "var(--neon-cyan)";
            btn.style.color = "#000";
            Mind.displayResponse({
                agent: "SISTEMA",
                response: paired ? "Sensor biométrico pareado." : "Sensor biométrico SIMULADO (Aguardando Pareamento BT)."
            });
        }
    },

    generateTap: async () => {
        const query = document.getElementById('mind-input').value;
        if (!query) return;

        const resp = await fetch(`api/codes.php?type=tap&q=${encodeURIComponent(query)}`);
        const data = await resp.json();

        Mind.displayResponse({
            agent: "TAP-CODE",
            response: `Batidas para "${query}": ${data.encoded}. Pronto para recepção física.`
        });
    },

    isStealthActive: false,
    toggleStealth: () => {
        Mind.isStealthActive = !Mind.isStealthActive;
        const btn = document.getElementById('mind-stealth-btn');
        if (Mind.isStealthActive) {
            btn.style.background = "var(--neon-red)";
            btn.style.color = "#fff";
            Mind.displayResponse({ agent: "SISTEMA", response: "Modo STEALTH (Camuflagem de Sinal) ativado." });
        } else {
            btn.style.background = "";
            btn.style.color = "var(--neon-cyan)";
            Mind.displayResponse({ agent: "SISTEMA", response: "Modo STEALTH desativado. Transmissão padrão restaurada." });
        }
    },

    generateDigital: async () => {
        const query = document.getElementById('mind-input').value;
        if (!query) return;

        if (Mind.isOTHActive) {
            SkywaveLink.sendOTH(query);
            return;
        }

        Mind.displayResponse({
            agent: "DIGITAL",
            response: Mind.isStealthActive ? "Gerando RAJADA DE RUÍDO (Stealth) Camuflada..." : "Gerando CHIRP tático (FSK) para dados compactos..."
        });

        const url = `api/codes.php?type=fsk&q=${encodeURIComponent(query)}&stealth=${Mind.isStealthActive}`;
        new Audio(url).play();
    },

    listenMode: 'MORSE', // 'MORSE', 'PHONETIC', 'TAP'

    startVoiceRecognition: () => {
        const SpeechRecognition = window.SpeechRecognition || window.webkitSpeechRecognition;
        if (!SpeechRecognition) {
            alert("Speech recognition not supported in this browser.");
            return;
        }

        const recognition = new SpeechRecognition();
        recognition.lang = 'en-US';
        recognition.interimResults = true;

        recognition.onresult = async (event) => {
            const transcript = event.results[event.results.length - 1][0].transcript;
            const label = document.getElementById('mind-active-label');
            if (label) label.innerText = `Voz: ${transcript}`;

            // Send to server for phonetic cleanup and translation
            try {
                const resp = await fetch(`api/phonetic.php?p=${encodeURIComponent(transcript)}`);
                const data = await resp.json();
                if (data.decoded) {
                    Mind.updateLiveTranscription(`${data.decoded} -> ${data.translated}`);
                }
            } catch (e) { }
        };

        recognition.onend = () => {
            if (AudioIntelligence.isListening && Mind.listenMode === 'PHONETIC') recognition.start();
        };

        recognition.start();
        AudioIntelligence.isListening = true; // Sync state
    },

    setListenMode: (mode) => {
        Mind.listenMode = mode;
        const btn = document.getElementById('mind-listen-btn');
        if (btn && !AudioIntelligence.isListening) btn.innerText = `🎙️ ${mode}`;
    },

    setAgent: (id) => {
        Mind.activeAgent = id;
        const status = document.getElementById('mind-active-label');
        if (status) status.innerText = `Agente: ${id}`;
    }
};

// Export or global access
window.Mind = Mind;
