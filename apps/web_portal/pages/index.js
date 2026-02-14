import Head from 'next/head';
import React, { useEffect, useMemo, useState } from 'react';
import { LanguageProvider, useLanguage } from '../contexts/LanguageContext';
import { BrowserSense } from '../lib/browser_discovery';

const edition = process.env.NEXT_PUBLIC_EDITION || 'standard';

const editions = ['mini', 'standard', 'server'];

const downloadTargets = [
    { id: 'android', ext: 'apk', base: 'resgatesos_android' },
    { id: 'tv', ext: 'apk', base: 'sos_tv_box' },
    { id: 'wear', ext: 'apk', base: 'resgatesos_wear' },
];

function Portal() {
    const { locale, changeLanguage, t, languages, hasTranslation, isRTL, isAuto } = useLanguage();
    const copy = t('portal');
    const {
        resources,
        injuries,
        meshHub,
        playbooks,
        quickStart,
        text = copy.text || {},
    } = copy;
    const [scenarioId, setScenarioId] = useState('isolamento');
    const [selectedResources, setSelectedResources] = useState(['solar', 'radio']);
    const [selectedInjuries, setSelectedInjuries] = useState([]);
    const [telemetrySummary, setTelemetrySummary] = useState(null);
    const [telemetryError, setTelemetryError] = useState('');
    const [telemetryLoading, setTelemetryLoading] = useState(false);

    // Mesh Hub State
    const [nodes, setNodes] = useState([]);
    const [messages, setMessages] = useState([]);
    const [inputMessage, setInputMessage] = useState('');
    const [activeRoom, setActiveRoom] = useState('SOS');
    const [contacts, setContacts] = useState([]);
    const [rooms, setRooms] = useState(['SOS', 'Community', 'Team-Alpha']);
    const [isScanning, setIsScanning] = useState(false);
    const [discoveryStatus, setDiscoveryStatus] = useState('');
    const [activeView, setActiveView] = useState('radar');
    const [isSidebarOpen, setIsSidebarOpen] = useState(false);

    const scenario = useMemo(
        () => playbooks.find((item) => item.id === scenarioId) || playbooks[0],
        [scenarioId, playbooks],
    );

    const resourceActions = useMemo(() => {
        const map = new Map(resources.map((r) => [r.id, r.actions]));
        return selectedResources.flatMap((id) => map.get(id) || []);
    }, [selectedResources, resources]);

    const injuryActions = useMemo(() => {
        const map = new Map(injuries.map((injury) => [injury.id, injury.steps]));
        return selectedInjuries.flatMap((id) => map.get(id) || []);
    }, [selectedInjuries, injuries]);

    const topTelemetryTypes = useMemo(() => {
        if (!telemetrySummary || !telemetrySummary.byType) return [];
        return Object.entries(telemetrySummary.byType)
            .sort((a, b) => b[1] - a[1])
            .slice(0, 5);
    }, [telemetrySummary]);

    useEffect(() => {
        let active = true;
        const loadTelemetry = async () => {
            setTelemetryLoading(true);
            try {
                const res = await fetch('/telemetry/summary');
                if (!res.ok) throw new Error('telemetry unavailable');
                const data = await res.json();
                if (active) {
                    setTelemetrySummary(data);
                    setTelemetryError('');
                }
            } catch (err) {
                if (active) {
                    setTelemetryError(text.telemetry?.errorNote || 'Telemetry unavailable');
                }
            } finally {
                if (active) setTelemetryLoading(false);
            }
        };
        loadTelemetry();
        return () => {
            active = false;
        };
    }, [text.telemetry]);

    const languageValue = isAuto ? 'auto' : locale;
    const serverNoteParts = useMemo(() => {
        const [pre, rest] = text.serverRunNote.split('SOS_WEB_ROOT');
        if (!rest) {
            return { pre: text.serverRunNote, mid1: '', mid2: '', post: '' };
        }
        const [mid1, restAfterHttp] = rest.split('SOS_HTTP_PORT');
        if (!restAfterHttp) {
            return { pre, mid1, mid2: '', post: '' };
        }
        const [mid2, post] = restAfterHttp.split('SOS_MESH_PORT');
        return { pre, mid1, mid2, post: post ?? '' };
    }, [text.serverRunNote]);

    const toggleList = (value, list, setList) => {
        if (list.includes(value)) {
            setList(list.filter((item) => item !== value));
        } else {
            setList([...list, value]);
        }
    };

    // Simulate Mesh Activity
    useEffect(() => {
        const demoNodes = [
            { id: 'Node-Alpha', lat: 10, lng: 20, type: 'Mobile', battery: 85 },
            { id: 'Node-Bravo', lat: -15, lng: 45, type: 'Server', battery: 100 },
            { id: 'Node-Charlie', lat: 30, lng: -10, type: 'Wearable', battery: 42 },
        ];
        setNodes(demoNodes);

        const initialMsgs = [
            { id: 1, from: 'System', text: 'Mesh Hub Initialized', timestamp: new Date().toLocaleTimeString(), room: 'SOS' },
            { id: 2, from: 'Node-Alpha', text: 'All clear at sector 4', timestamp: new Date().toLocaleTimeString(), room: 'SOS' },
        ];
        setMessages(initialMsgs);

        const demoContacts = [
            { id: 'c1', name: 'Commander Mike', status: 'Online', distance: '120m' },
            { id: 'c2', name: 'Rescue-1', status: 'Away', distance: '450m' },
            { id: 'c3', name: 'Support-B', status: 'Offline', distance: 'unknown' },
        ];
        setContacts(demoContacts);
    }, []);

    const sendMessage = () => {
        if (!inputMessage.trim()) return;
        const newMsg = {
            id: Date.now(),
            from: 'You (Local)',
            text: inputMessage,
            timestamp: new Date().toLocaleTimeString(),
            room: activeRoom,
        };
        setMessages([...messages, newMsg]);
        setInputMessage('');
    };

    const handleBluetoothScan = async () => {
        setIsScanning(true);
        setDiscoveryStatus('Scanning Bluetooth...');
        try {
            const pos = await BrowserSense.getCurrentPosition().catch(() => ({ lat: 0, lng: 0 }));
            const device = await BrowserSense.scanBluetooth();
            if (device) {
                const newNode = {
                    id: device.id,
                    lat: (pos.lat + (Math.random() * 2 - 1) * 0.01).toFixed(4),
                    lng: (pos.lng + (Math.random() * 2 - 1) * 0.01).toFixed(4),
                    type: 'BLE-Found',
                    battery: 100,
                    name: device.name
                };
                setNodes(prev => [...prev, newNode]);
                setDiscoveryStatus(`Added node: ${device.name}`);
            }
        } catch (e) {
            setDiscoveryStatus('Bluetooth scan failed.');
        } finally {
            setIsScanning(false);
        }
    };

    const handleNetworkProbe = async () => {
        setIsScanning(true);
        setDiscoveryStatus('Probing network...');
        await BrowserSense.probeLocalNetwork((newNode) => {
            setNodes(prev => {
                if (prev.find(n => n.id === newNode.id)) return prev;
                return [...prev, newNode];
            });
            setDiscoveryStatus(`Found Hub at ${newNode.url}`);
        });
        setTimeout(() => {
            setIsScanning(false);
            setDiscoveryStatus('');
        }, 5000);
    };

    return (
        <>
            <Head>
                <title>{text.metaTitle} | Tactical Core</title>
                <meta name="description" content={text.metaDescription} />
            </Head>
            <div className={`dashboard-wrapper ${isRTL ? 'rtl' : 'ltr'}`}>
                {/* Sidebar Navigation */}
                <aside className={`dashboard-sidebar ${isSidebarOpen ? 'open' : ''}`}>
                    <div className="sidebar-logo">
                        <span className="logo-text">SOS</span>
                        <div className="status-indicator online"></div>
                    </div>

                    <nav className="sidebar-nav">
                        <button
                            className={`nav-item ${activeView === 'radar' ? 'active' : ''}`}
                            onClick={() => setActiveView('radar')}
                            title="Mesh Map"
                        >
                            <span className="nav-icon">🛰️</span>
                            <span className="nav-label">Radar</span>
                        </button>
                        <button
                            className={`nav-item ${activeView === 'comms' ? 'active' : ''}`}
                            onClick={() => setActiveView('comms')}
                            title="Communications"
                        >
                            <span className="nav-icon">💬</span>
                            <span className="nav-label">Comms</span>
                        </button>
                        <button
                            className={`nav-item ${activeView === 'logistics' ? 'active' : ''}`}
                            onClick={() => setActiveView('logistics')}
                            title="Resource Management"
                        >
                            <span className="nav-icon">📋</span>
                            <span className="nav-label">Logistics</span>
                        </button>
                        <button
                            className={`nav-item ${activeView === 'telemetry' ? 'active' : ''}`}
                            onClick={() => setActiveView('telemetry')}
                            title="System Metrics"
                        >
                            <span className="nav-icon">📊</span>
                            <span className="nav-label">Metrics</span>
                        </button>
                        <button
                            className={`nav-item ${activeView === 'registry' ? 'active' : ''}`}
                            onClick={() => setActiveView('registry')}
                            title="Technology & Downloads"
                        >
                            <span className="nav-icon">⚙️</span>
                            <span className="nav-label">Registry</span>
                        </button>
                    </nav>

                    <div className="sidebar-footer">
                        <select
                            value={languageValue}
                            onChange={(e) => changeLanguage(e.target.value)}
                            className="sidebar-lang-select"
                        >
                            <option value="auto">Auto</option>
                            {languages.map(l => <option key={l.code} value={l.code}>{l.name}</option>)}
                        </select>
                    </div>
                </aside>

                <main className="dashboard-main">
                    {/* Top Status Bar */}
                    <header className="dashboard-topbar">
                        <div className="status-group">
                            <span className="status-bit"><strong>NODE:</strong> {edition}</span>
                            <span className="status-bit"><strong>MODE:</strong> {text.panelMode}</span>
                            <span className="status-bit"><strong>SYS:</strong> V4.0.0</span>
                        </div>
                        <div className="topbar-actions">
                            <button onClick={handleBluetoothScan} className="btn-action" disabled={isScanning}>📡 BLE SCAN</button>
                            <button onClick={handleNetworkProbe} className="btn-action" disabled={isScanning}>🌐 PROBE</button>
                        </div>
                    </header>

                    <div className="dashboard-content">
                        {activeView === 'radar' && (
                            <div className="view-radar full-bleed">
                                <div className="radar-frame">
                                    <div className="radar-display">
                                        <div className="radar-grid">
                                            <div className="radar-sweep"></div>
                                            {nodes.map((node) => (
                                                <div
                                                    key={node.id}
                                                    className={`node-dot ${node.type.toLowerCase()}`}
                                                    style={{ left: `${50 + node.lng}%`, top: `${50 - node.lat}%` }}
                                                    title={`${node.id} (${node.type})`}
                                                >
                                                    <span className="node-label">{node.id}</span>
                                                </div>
                                            ))}
                                            <div className="center-dot">HQ</div>
                                        </div>
                                    </div>
                                    <div className="radar-side-info">
                                        <h3>{meshHub.radarTitle}</h3>
                                        <p className="dimmed">{meshHub.radarNote}</p>
                                        <div className="node-list-tactical">
                                            {nodes.map(n => (
                                                <div key={n.id} className="node-item-mini">
                                                    <span className={`type-tag ${n.type.toLowerCase()}`}>{n.type[0]}</span>
                                                    <span className="n-id">{n.id}</span>
                                                    <span className="n-bat">{n.battery}%</span>
                                                </div>
                                            ))}
                                        </div>
                                    </div>
                                </div>
                            </div>
                        )}

                        {activeView === 'comms' && (
                            <div className="view-comms">
                                <div className="comms-layout-tactical">
                                    <div className="comms-channel-list">
                                        <h4>{meshHub.roomsTitle}</h4>
                                        {rooms.map(room => (
                                            <button
                                                key={room}
                                                className={`channel-btn ${activeRoom === room ? 'active' : ''}`}
                                                onClick={() => setActiveRoom(room)}
                                            >
                                                # {room}
                                            </button>
                                        ))}
                                        <h4 style={{ marginTop: '20px' }}>{meshHub.contactsTitle}</h4>
                                        <div className="contact-list-mini">
                                            {contacts.map(c => (
                                                <div key={c.id} className={`contact-pill ${c.status.toLowerCase()}`}>
                                                    {c.name} <small>{c.distance}</small>
                                                </div>
                                            ))}
                                        </div>
                                    </div>
                                    <div className="comms-chat-area">
                                        <div className="chat-log">
                                            {messages.filter(m => m.room === activeRoom || m.room === 'SOS').map((msg) => (
                                                <div key={msg.id} className="chat-msg">
                                                    <span className="msg-meta">[{msg.timestamp}] {msg.from}:</span>
                                                    <span className="msg-body">{msg.text}</span>
                                                </div>
                                            ))}
                                        </div>
                                        <div className="chat-input-wrapper">
                                            <input
                                                type="text"
                                                value={inputMessage}
                                                onChange={(e) => setInputMessage(e.target.value)}
                                                onKeyPress={(e) => e.key === 'Enter' && sendMessage()}
                                                placeholder={meshHub.inputPlaceholder}
                                            />
                                            <button onClick={sendMessage}>{meshHub.sendBtn}</button>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        )}

                        {activeView === 'logistics' && (
                            <div className="view-logistics scrollable">
                                <div className="logistics-grid">
                                    <div className="logistics-card">
                                        <h3>{text.assistantSimTitle}</h3>
                                        <div className="sim-controls">
                                            <select value={scenarioId} onChange={(e) => setScenarioId(e.target.value)}>
                                                {playbooks.map(p => <option key={p.id} value={p.id}>{p.title}</option>)}
                                            </select>
                                            <div className="resource-chips">
                                                {resources.map(r => (
                                                    <button
                                                        key={r.id}
                                                        className={`chip ${selectedResources.includes(r.id) ? 'active' : ''}`}
                                                        onClick={() => toggleList(r.id, selectedResources, setSelectedResources)}
                                                    >
                                                        {r.label}
                                                    </button>
                                                ))}
                                            </div>
                                        </div>
                                    </div>
                                    <div className="logistics-card result">
                                        <h3>{scenario.title}</h3>
                                        <div className="result-sections">
                                            <div className="res-sec">
                                                <label>{text.assistantPrioritiesLabel}</label>
                                                <ul>{scenario.priority.map(p => <li key={p}>{p}</li>)}</ul>
                                            </div>
                                            <div className="res-sec">
                                                <label>{text.assistantSafetyLabel}</label>
                                                <ul>{scenario.safety.map(s => <li key={s}>{s}</li>)}</ul>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        )}

                        {activeView === 'telemetry' && (
                            <div className="view-telemetry scrollable">
                                <div className="telemetry-dashboard">
                                    <div className="tel-main-stats">
                                        <div className="stat-box">
                                            <span className="val">{telemetrySummary?.total || '0'}</span>
                                            <label>{text.telemetry.eventsLabel}</label>
                                        </div>
                                        <div className="stat-box">
                                            <span className="val">{telemetrySummary?.nodes || '0'}</span>
                                            <label>{text.telemetry.nodesLabel}</label>
                                        </div>
                                    </div>
                                    <div className="tel-chart-mock">
                                        <h3>{text.telemetry.typesTitle}</h3>
                                        <div className="type-list-tactical">
                                            {topTelemetryTypes.map(([type, count]) => (
                                                <div key={type} className="type-row">
                                                    <span className="t-name">{type}</span>
                                                    <div className="t-bar-wrap"><div className="t-bar" style={{ width: `${Math.min(100, count)}%` }}></div></div>
                                                    <span className="t-count">{count}</span>
                                                </div>
                                            ))}
                                        </div>
                                    </div>
                                </div>
                            </div>
                        )}

                        {activeView === 'registry' && (
                            <div className="view-registry scrollable">
                                <div className="registry-container">
                                    <h3>{text.downloadsTitle}</h3>
                                    <div className="download-grid-tactical">
                                        {downloadTargets.map(target => (
                                            <div key={target.id} className="dl-card">
                                                <span className="dl-platform">{target.id.toUpperCase()}</span>
                                                <a href={`/downloads/${edition}/${target.base}_${edition}.${target.ext}`} className="dl-btn">
                                                    Download v4.0.0
                                                </a>
                                            </div>
                                        ))}
                                    </div>
                                    <h3 style={{ marginTop: '40px' }}>{text.techTitle}</h3>
                                    <div className="tech-matrix-mini">
                                        {text.techCards.map(tc => (
                                            <div key={tc.title} className="tech-card-mini">
                                                <h4>{tc.title}</h4>
                                                <ul>{tc.items.map(i => <li key={i}>{i}</li>)}</ul>
                                            </div>
                                        ))}
                                    </div>
                                </div>
                            </div>
                        )}
                    </div>
                    {discoveryStatus && <div className="global-notification">{discoveryStatus}</div>}
                </main>
            </div>

            <style jsx>{`
                :global(body) {
                    margin: 0;
                    padding: 0;
                    font-family: 'Space Grotesk', 'Inter', -apple-system, sans-serif;
                    background: #020408;
                    color: #e6f1ff;
                    overflow: hidden;
                }

                * { box-sizing: border-box; }
                ::-webkit-scrollbar { width: 6px; }
                ::-webkit-scrollbar-thumb { background: rgba(0, 161, 241, 0.3); border-radius: 10px; }

                .dashboard-wrapper {
                    display: grid;
                    grid-template-columns: 85px 1fr;
                    height: 100vh;
                    width: 100vw;
                    background: radial-gradient(circle at 50% 50%, #0a1018 0%, #020408 100%);
                }

                .dashboard-wrapper.rtl { direction: rtl; grid-template-columns: 1fr 85px; }

                /* Sidebar */
                .dashboard-sidebar {
                    background: rgba(5, 8, 12, 0.85);
                    backdrop-filter: blur(20px);
                    border-right: 1px solid rgba(0, 161, 241, 0.15);
                    display: flex;
                    flex-direction: column;
                    align-items: center;
                    padding: 24px 0;
                    z-index: 1000;
                }

                .sidebar-logo {
                    width: 45px;
                    height: 45px;
                    background: linear-gradient(135deg, #00a1f1, #00dca5);
                    border-radius: 12px;
                    display: grid;
                    place-items: center;
                    font-weight: 900;
                    color: #000;
                    margin-bottom: 40px;
                    box-shadow: 0 0 20px rgba(0, 161, 241, 0.3);
                }

                .status-indicator {
                    width: 10px;
                    height: 10px;
                    border-radius: 50%;
                    border: 2px solid #05080c;
                    background: #00ff00;
                    box-shadow: 0 0 10px #00ff00;
                }

                .sidebar-nav { flex: 1; display: flex; flex-direction: column; gap: 16px; }

                .nav-item {
                    background: transparent; border: none; color: rgba(255, 255, 255, 0.3);
                    padding: 12px; border-radius: 14px; cursor: pointer;
                    transition: all 0.25s; display: flex; flex-direction: column; align-items: center; gap: 6px;
                }

                .nav-icon { font-size: 1.4rem; }
                .nav-label { font-size: 0.6rem; font-weight: 800; text-transform: uppercase; }

                .nav-item:hover { color: #fff; background: rgba(255, 255, 255, 0.05); }
                .nav-item.active { color: #00a1f1; background: rgba(0, 161, 241, 0.1); }

                .sidebar-footer { padding-top: 20px; border-top: 1px solid rgba(255, 255, 255, 0.05); }
                .sidebar-lang-select { background: transparent; border: none; color: rgba(255, 255, 255, 0.5); font-size: 0.75rem; cursor: pointer; }

                /* Main Area */
                .dashboard-main { display: flex; flex-direction: column; overflow: hidden; position: relative; }
                .dashboard-topbar {
                    height: 64px; padding: 0 32px; display: flex; justify-content: space-between; align-items: center;
                    background: rgba(10, 16, 24, 0.4); backdrop-filter: blur(10px); border-bottom: 1px solid rgba(255, 255, 255, 0.05);
                }

                .status-group { display: flex; gap: 24px; }
                .status-bit { font-size: 0.75rem; color: #7dd3ff; font-weight: 600; text-transform: uppercase; }
                .status-bit strong { color: rgba(125, 211, 255, 0.5); margin-right: 4px; }

                .btn-action {
                    background: rgba(0, 161, 241, 0.08); border: 1px solid rgba(0, 161, 241, 0.2);
                    color: #7dd3ff; padding: 8px 16px; border-radius: 8px; font-size: 0.7rem; font-weight: 800;
                    cursor: pointer; transition: all 0.2s; text-transform: uppercase;
                }
                .btn-action:hover { background: rgba(0, 161, 241, 0.15); border-color: rgba(0, 161, 241, 0.4); }

                .dashboard-content { flex: 1; position: relative; overflow: hidden; }
                .full-bleed { width: 100%; height: 100%; }
                .scrollable { overflow-y: auto; padding: 40px; height: 100%; }

                /* View Specifics */
                .view-radar { display: flex; height: 100%; }
                .radar-frame { flex: 1; display: grid; grid-template-columns: 1fr 340px; height: 100%; }
                .radar-display { background: #030508; position: relative; overflow: hidden; }
                .radar-side-info { background: rgba(5, 8, 12, 0.6); padding: 40px; border-left: 1px solid rgba(255, 255, 255, 0.05); }

                .radar-grid { 
                    width: 100%; height: 100%; position: relative; 
                    background-image: radial-gradient(circle, rgba(0, 161, 241, 0.05) 1px, transparent 1px);
                    background-size: 60px 60px;
                }

                .radar-sweep {
                    position: absolute; width: 200%; height: 200%; top: -50%; left: -50%;
                    background: conic-gradient(from 0deg, rgba(0, 161, 241, 0.15) 0%, transparent 20%);
                    animation: sweep 8s linear infinite; pointer-events: none;
                }
                @keyframes sweep { from { transform: rotate(0deg); } to { transform: rotate(360deg); } }

                .node-dot {
                    position: absolute; width: 12px; height: 12px; border-radius: 50%; border: 2px solid #fff;
                    transform: translate(-50%, -50%); transition: all 0.5s cubic-bezier(0.4, 0, 0.2, 1);
                }
                .node-dot.server { background: #ff00ff; box-shadow: 0 0 15px #ff00ff; }
                .node-dot.mobile { background: #00ff00; box-shadow: 0 0 15px #00ff00; }
                .node-dot.ble-found { background: #00a1f1; box-shadow: 0 0 15px #00a1f1; }
                .node-label { position: absolute; top: 16px; left: 50%; transform: translateX(-50%); font-size: 0.6rem; color: #fff; font-weight: 800; white-space: nowrap; }

                .center-dot {
                    position: absolute; left: 50%; top: 50%; width: 20px; height: 20px;
                    background: #fff; border-radius: 50%; transform: translate(-50%, -50%);
                    display: grid; place-items: center; font-size: 0.55rem; color: #000; font-weight: 900;
                    box-shadow: 0 0 30px rgba(255, 255, 255, 0.5); z-index: 10;
                }

                .comms-layout-tactical { display: grid; grid-template-columns: 280px 1fr; height: 100%; }
                .comms-channel-list { background: rgba(5, 8, 12, 0.4); border-right: 1px solid rgba(255, 255, 255, 0.05); padding: 32px; }
                .channel-btn { width: 100%; text-align: left; padding: 12px; background: transparent; color: #888; border: none; border-radius: 10px; cursor: pointer; }
                .channel-btn.active { background: rgba(0, 161, 241, 0.1); color: #00a1f1; }

                .chat-log { flex: 1; padding: 32px; overflow-y: auto; display: flex; flex-direction: column; gap: 12px; }
                .chat-msg { background: rgba(255, 255, 255, 0.02); padding: 12px 16px; border-radius: 12px; border: 1px solid rgba(255, 255, 255, 0.05); }
                .msg-meta { font-size: 0.7rem; color: #00a1f1; font-weight: 800; }

                .chat-input-wrapper { padding: 24px 32px; background: rgba(5, 8, 12, 0.8); display: flex; gap: 16px; }
                .chat-input-wrapper input { flex: 1; background: #0c111a; border: 1px solid #333; color: #fff; padding: 12px 24px; border-radius: 99px; outline: none; }
                .chat-input-wrapper button { background: #00a1f1; color: #000; border: none; padding: 0 24px; border-radius: 99px; font-weight: 900; cursor: pointer; }

                .tel-main-stats { display: flex; gap: 24px; margin-bottom: 40px; }
                .stat-box { flex: 1; background: rgba(0, 161, 241, 0.05); padding: 28px; border-radius: 20px; border: 1px solid rgba(0, 161, 241, 0.1); }
                .stat-box .val { font-size: 2.8rem; font-weight: 900; color: #fff; display: block; }
                .stat-box label { font-size: 0.7rem; font-weight: 800; color: #00a1f1; text-transform: uppercase; }

                .download-grid-tactical { display: grid; grid-template-columns: repeat(auto-fill, minmax(220px, 1fr)); gap: 16px; }
                .dl-card { background: rgba(255, 255, 255, 0.02); padding: 24px; border-radius: 18px; border: 1px solid rgba(255, 255, 255, 0.06); }
                .dl-btn { display: block; margin-top: 12px; text-decoration: none; text-align: center; background: #00a1f1; color: #000; font-weight: 900; padding: 10px; border-radius: 8px; }

                .global-notification { position: absolute; bottom: 32px; right: 32px; background: #00dca5; color: #000; padding: 12px 24px; border-radius: 12px; font-weight: 900; box-shadow: 0 10px 40px rgba(0, 220, 165, 0.3); }
                h3 { margin-bottom: 20px; font-weight: 900; }
                .dimmed { color: rgba(255, 255, 255, 0.4); font-size: 0.9rem; }

            `}</style>
        </>
    );
}

export default function Home() {
    return (
        <LanguageProvider>
            <Portal />
        </LanguageProvider>
    );
}
