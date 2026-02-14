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
                <title>{text.metaTitle}</title>
                <meta name="description" content={text.metaDescription} />
            </Head>
            <div className="page" dir={isRTL ? 'rtl' : 'ltr'}>
                <div className="language-bar">
                    <label className="language-label">
                        <span>{text.languageSelector}</span>
                        <select
                            value={languageValue}
                            onChange={(event) => changeLanguage(event.target.value)}
                        >
                            <option value="auto">{text.languageAuto}</option>
                            {languages.map((lang) => (
                                <option key={lang.code} value={lang.code}>
                                    {lang.name}
                                </option>
                            ))}
                        </select>
                    </label>
                    {!hasTranslation && (
                        <span className="language-note">{text.languageFallback}</span>
                    )}
                </div>
                <header className="hero">
                    <div className="hero-copy">
                        <p className="eyebrow">{text.heroEyebrow}</p>
                        <h1>{text.heroTitle}</h1>
                        <p className="lead">{text.heroLead}</p>
                        <div className="hero-actions">
                            <a href="#downloads" className="btn primary">
                                {text.heroActions.downloads}
                            </a>
                            <a href="#assistant" className="btn ghost">
                                {text.heroActions.assistant}
                            </a>
                        </div>
                        <div className="badge-row">
                            {text.heroBadges.map((badge) => (
                                <span className="badge" key={badge}>
                                    {badge}
                                </span>
                            ))}
                        </div>
                    </div>
                    <div className="hero-panel">
                        <div className="panel-card">
                            <p className="panel-title">{text.panelTitle}</p>
                            <div className="panel-grid">
                                <div>
                                    <span className="panel-label">{text.panelLabels.edition}</span>
                                    <span className="panel-value">{edition}</span>
                                </div>
                                <div>
                                    <span className="panel-label">{text.panelLabels.mode}</span>
                                    <span className="panel-value">{text.panelMode}</span>
                                </div>
                                <div>
                                    <span className="panel-label">{text.panelLabels.http}</span>
                                    <span className="panel-value">:8080</span>
                                </div>
                                <div>
                                    <span className="panel-label">{text.panelLabels.mesh}</span>
                                    <span className="panel-value">:4000</span>
                                </div>
                            </div>
                            <div className="panel-footer">
                                <p>{text.panelFooter}</p>
                            </div>
                        </div>
                        <div className="pulse-ring">
                            <div className="pulse-core">SOS</div>
                        </div>
                    </div>
                </header>

                <section className="section" id="como-funciona">
                    <div className="section-title">
                        <h2>{text.howItWorksTitle}</h2>
                        <p>{text.howItWorksLead}</p>
                    </div>
                    <div className="grid four">
                        {quickStart.map((item, index) => (
                            <div className="card" key={item.title} style={{ '--delay': `${index * 0.05}s` }}>
                                <h3>{item.title}</h3>
                                <p>{item.text}</p>
                            </div>
                        ))}
                    </div>
                </section>

                <section className="section" id="mesh-hub">
                    <div className="section-title">
                        <h2>{meshHub.title}</h2>
                        <p>{meshHub.lead}</p>
                    </div>
                    <div className="mesh-container">
                        <div className="mesh-radar-view">
                            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                                <h3>{meshHub.radarTitle}</h3>
                                <div className="discovery-actions" style={{ display: 'flex', gap: '8px' }}>
                                    <button
                                        onClick={handleBluetoothScan}
                                        className="btn ghost small"
                                        disabled={isScanning}
                                        title="Scan via Bluetooth"
                                    >
                                        📡 BLE
                                    </button>
                                    <button
                                        onClick={handleNetworkProbe}
                                        className="btn ghost small"
                                        disabled={isScanning}
                                        title="Probe Network"
                                    >
                                        🌐 Probe
                                    </button>
                                </div>
                            </div>
                            {discoveryStatus && <p className="discovery-note" style={{ fontSize: '0.8rem', color: '#7dd3ff', margin: '4px 0' }}>{discoveryStatus}</p>}
                            <div className="radar-display">
                                <div className="radar-grid">
                                    <div className="radar-sweep"></div>
                                    {nodes.map((node) => (
                                        <div
                                            key={node.id}
                                            className={`node-dot ${node.type.toLowerCase()}`}
                                            style={{
                                                left: `${50 + node.lng}%`,
                                                top: `${50 - node.lat}%`,
                                            }}
                                            title={`${node.id} (${node.type}) - ${node.battery}%`}
                                        >
                                            <span className="node-label">{node.id}</span>
                                        </div>
                                    ))}
                                    <div className="center-dot">You</div>
                                </div>
                            </div>
                            <p className="note">{meshHub.radarNote}</p>
                        </div>

                        <div className="mesh-comms-view">
                            <div className="comms-header">
                                <h3>{meshHub.messagingTitle}</h3>
                            </div>

                            <div className="comms-main">
                                <div className="comms-sidebar">
                                    <div className="sidebar-section">
                                        <h4>{meshHub.roomsTitle}</h4>
                                        <div className="room-list">
                                            {rooms.map(room => (
                                                <button
                                                    key={room}
                                                    className={activeRoom === room ? 'active' : ''}
                                                    onClick={() => setActiveRoom(room)}
                                                >
                                                    # {room}
                                                </button>
                                            ))}
                                        </div>
                                    </div>
                                    <div className="sidebar-section">
                                        <h4>{meshHub.contactsTitle}</h4>
                                        <div className="contact-list">
                                            {contacts.map(contact => (
                                                <div key={contact.id} className={`contact-item ${contact.status.toLowerCase()}`}>
                                                    <span className="contact-name">{contact.name}</span>
                                                    <span className="contact-dist">{contact.distance}</span>
                                                </div>
                                            ))}
                                        </div>
                                    </div>
                                </div>

                                <div className="comms-chat">
                                    <div className="active-room-header"># {activeRoom}</div>
                                    <div className="message-list">
                                        {messages.filter(m => m.room === activeRoom || m.room === 'SOS' || activeRoom === 'SOS').map((msg) => (
                                            <div key={msg.id} className="message-item">
                                                <span className="msg-from">{msg.from}:</span>
                                                <span className="msg-text">{msg.text}</span>
                                                <span className="msg-time">{msg.timestamp}</span>
                                            </div>
                                        ))}
                                    </div>
                                    <div className="message-input">
                                        <input
                                            type="text"
                                            placeholder={meshHub.inputPlaceholder}
                                            value={inputMessage}
                                            onChange={(e) => setInputMessage(e.target.value)}
                                            onKeyPress={(e) => e.key === 'Enter' && sendMessage()}
                                        />
                                        <button onClick={sendMessage}>{meshHub.sendBtn}</button>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </section>

                <section className="section" id="assistant">
                    <div className="section-title">
                        <h2>{text.assistantTitle}</h2>
                        <p>{text.assistantLead}</p>
                    </div>
                    <div className="grid two">
                        <div className="card wizard">
                            <h3>{text.assistantSimTitle}</h3>
                            <label>
                                {text.assistantScenarioLabel}
                                <select
                                    value={scenarioId}
                                    onChange={(event) => setScenarioId(event.target.value)}
                                >
                                    {playbooks.map((item) => (
                                        <option key={item.id} value={item.id}>
                                            {item.title}
                                        </option>
                                    ))}
                                </select>
                            </label>
                            <div className="check-group">
                                <p className="group-title">{text.assistantResourcesLabel}</p>
                                {resources.map((resource) => (
                                    <label key={resource.id} className="checkbox">
                                        <input
                                            type="checkbox"
                                            checked={selectedResources.includes(resource.id)}
                                            onChange={() => toggleList(resource.id, selectedResources, setSelectedResources)}
                                        />
                                        {resource.label}
                                    </label>
                                ))}
                            </div>
                            <div className="check-group">
                                <p className="group-title">{text.assistantInjuriesLabel}</p>
                                {injuries.map((injury) => (
                                    <label key={injury.id} className="checkbox">
                                        <input
                                            type="checkbox"
                                            checked={selectedInjuries.includes(injury.id)}
                                            onChange={() => toggleList(injury.id, selectedInjuries, setSelectedInjuries)}
                                        />
                                        {injury.label}
                                    </label>
                                ))}
                            </div>
                            <div className="api-box">
                                <p className="group-title">{text.assistantApiLabel}</p>
                                <code>
                                    GET /assistant?scenario={scenarioId}&resources=solar,radio&injuries=sangramento
                                </code>
                            </div>
                        </div>
                        <div className="card wizard-result">
                            <h3>{scenario.title}</h3>
                            <p className="muted">{scenario.summary}</p>
                            <div className="list">
                                <p className="group-title">{text.assistantPrioritiesLabel}</p>
                                {scenario.priority.map((item) => (
                                    <span key={item}>{item}</span>
                                ))}
                            </div>
                            <div className="list">
                                <p className="group-title">{text.assistantSafetyLabel}</p>
                                {scenario.safety.map((item) => (
                                    <span key={item}>{item}</span>
                                ))}
                            </div>
                            <div className="list">
                                <p className="group-title">{text.assistantCoordinationLabel}</p>
                                {scenario.coordination.map((item) => (
                                    <span key={item}>{item}</span>
                                ))}
                            </div>
                            {scenario.communications && (
                                <div className="list">
                                    <p className="group-title">{text.assistantCommsLabel}</p>
                                    {scenario.communications.map((item) => (
                                        <span key={item}>{item}</span>
                                    ))}
                                </div>
                            )}
                            {resourceActions.length > 0 && (
                                <div className="list">
                                    <p className="group-title">{text.assistantResourceActionsLabel}</p>
                                    {resourceActions.map((item, index) => (
                                        <span key={`${item}-${index}`}>{item}</span>
                                    ))}
                                </div>
                            )}
                            {injuryActions.length > 0 && (
                                <div className="list">
                                    <p className="group-title">{text.assistantFirstAidLabel}</p>
                                    {injuryActions.map((item, index) => (
                                        <span key={`${item}-${index}`}>{item}</span>
                                    ))}
                                </div>
                            )}
                            <p className="disclaimer">{text.assistantDisclaimer}</p>
                        </div>
                    </div>
                </section>

                <section className="section" id="servidor">
                    <div className="section-title">
                        <h2>{text.serverTitle}</h2>
                        <p>{text.serverLead}</p>
                    </div>
                    <div className="grid two">
                        <div className="card">
                            <h3>{text.serverRunTitle}</h3>
                            <code>
                                java -jar resgatesos_java_server.jar --web-root ./web --port 8080 --mesh-port 4000
                            </code>
                            <p className="muted">
                                {serverNoteParts.pre}
                                <strong>SOS_WEB_ROOT</strong>
                                {serverNoteParts.mid1}
                                <strong>SOS_HTTP_PORT</strong>
                                {serverNoteParts.mid2}
                                <strong> SOS_MESH_PORT</strong>
                                {serverNoteParts.post}
                            </p>
                        </div>
                        <div className="card">
                            <h3>{text.serverOffersTitle}</h3>
                            <div className="list">
                                {text.serverOffers.map((item) => (
                                    <span key={item}>{item}</span>
                                ))}
                            </div>
                        </div>
                    </div>
                </section>

                <section className="section" id="telemetria">
                    <div className="section-title">
                        <h2>{text.telemetry.title}</h2>
                        <p>{text.telemetry.lead}</p>
                    </div>
                    <div className="grid two">
                        <div className="card">
                            <h3>{text.telemetry.statusTitle}</h3>
                            <div className="list">
                                <span>
                                    {text.telemetry.statusLabel}:{' '}
                                    {telemetryLoading
                                        ? text.telemetry.statusLoading
                                        : telemetrySummary
                                            ? text.telemetry.statusReady
                                            : text.telemetry.statusUnavailable}
                                </span>
                                <span>
                                    {text.telemetry.eventsLabel}:{' '}
                                    {telemetrySummary?.total ?? '—'}
                                </span>
                                <span>
                                    {text.telemetry.nodesLabel}:{' '}
                                    {telemetrySummary?.nodes ?? '—'}
                                </span>
                                <span>
                                    {text.telemetry.rangeLabel}:{' '}
                                    {telemetrySummary?.from && telemetrySummary?.to
                                        ? `${telemetrySummary.from} → ${telemetrySummary.to}`
                                        : '—'}
                                </span>
                            </div>
                            {telemetryError && (
                                <p className="disclaimer">{telemetryError}</p>
                            )}
                        </div>
                        <div className="card">
                            <h3>{text.telemetry.typesTitle}</h3>
                            <div className="list">
                                {topTelemetryTypes.length > 0 ? (
                                    topTelemetryTypes.map(([type, count]) => (
                                        <span key={type}>{type}: {count}</span>
                                    ))
                                ) : (
                                    <span>{text.telemetry.emptyTypes}</span>
                                )}
                            </div>
                            <p className="section-note">{text.telemetry.note}</p>
                        </div>
                    </div>
                </section>

                <section className="section" id="tecnologia">
                    <div className="section-title">
                        <h2>{text.techTitle}</h2>
                        <p>{text.techLead}</p>
                    </div>
                    <div className="grid three">
                        {text.techCards.map((card) => (
                            <div className="card" key={card.title}>
                                <h3>{card.title}</h3>
                                <div className="list">
                                    {card.items.map((item) => (
                                        <span key={item}>{item}</span>
                                    ))}
                                </div>
                            </div>
                        ))}
                    </div>
                </section>

                <section className="section" id="downloads">
                    <div className="section-title">
                        <h2>{text.downloadsTitle}</h2>
                        <p>{text.downloadsLead}</p>
                    </div>
                    <div className="downloads">
                        {editions.map((ed) => (
                            <div key={ed} className="download-card">
                                <div className="download-head">
                                    <h3>{ed.toUpperCase()}</h3>
                                    <span className="tag">{ed}</span>
                                </div>
                                <div className="download-links">
                                    {downloadTargets.map((item) => (
                                        <a
                                            key={`${ed}-${item.base}`}
                                            href={`downloads/${ed}/${item.base}_${ed}.${item.ext}`}
                                        >
                                            {downloadCopy.targets[item.id]}
                                        </a>
                                    ))}
                                    <a href={`downloads/${ed}/resgatesos_windows_${ed}.zip`}>
                                        {downloadCopy.windowsZip}
                                    </a>
                                    <a href={`downloads/${ed}/resgatesos_java_${ed}.zip`}>
                                        {downloadCopy.javaZip}
                                    </a>
                                    <a href={`downloads/${ed}/resgatesos_java_${ed}.jar`}>
                                        {downloadCopy.javaJar}
                                    </a>
                                </div>
                                <p className="download-note">{text.downloadsNote}</p>
                            </div>
                        ))}
                    </div>
                </section>

                <section className="section" id="checklists">
                    <div className="section-title">
                        <h2>{text.checklistsTitle}</h2>
                        <p>{text.checklistsLead}</p>
                    </div>
                    <div className="grid three">
                        {resilienceChecklists.map((group) => (
                            <div className="card" key={group.title}>
                                <h3>{group.title}</h3>
                                <div className="list">
                                    {group.items.map((item) => (
                                        <span key={item}>{item}</span>
                                    ))}
                                </div>
                            </div>
                        ))}
                    </div>
                </section>

                <section className="section" id="comunicacao">
                    <div className="section-title">
                        <h2>{text.commsTitle}</h2>
                        <p>{text.commsLead}</p>
                    </div>
                    <div className="grid two">
                        <div className="card">
                            <h3>{text.commsProtocolsTitle}</h3>
                            <div className="list">
                                {commsBasics.map((item) => (
                                    <span key={item}>{item}</span>
                                ))}
                            </div>
                            {commsCodes.map((block) => (
                                <div className="comms-block" key={block.title}>
                                    <p className="group-title">{block.title}</p>
                                    <div className="list">
                                        {block.items.map((item) => (
                                            <span key={item}>{item}</span>
                                        ))}
                                    </div>
                                </div>
                            ))}
                        </div>
                        <div className="card">
                            <h3>{text.phoneticTitle}</h3>
                            <div className="phonetic-grid">
                                {phoneticAlphabet.map((item) => (
                                    <div className="phonetic-item" key={item.letter}>
                                        <span className="phonetic-letter">{item.letter}</span>
                                        <span className="phonetic-code">{item.code}</span>
                                    </div>
                                ))}
                            </div>
                            <p className="section-note">{text.phoneticNote}</p>
                        </div>
                    </div>
                </section>

                <section className="section" id="preparacao">
                    <div className="section-title">
                        <h2>{text.prepTitle}</h2>
                        <p>{text.prepLead}</p>
                    </div>
                    <div className="grid three">
                        {preparednessChecklist.map((group) => (
                            <div className="card" key={group.title}>
                                <h3>{group.title}</h3>
                                <div className="list">
                                    {group.items.map((item) => (
                                        <span key={item}>{item}</span>
                                    ))}
                                </div>
                            </div>
                        ))}
                    </div>
                </section>
                <section className="section" id="fema-preparedness">
                    <div className="section-title">
                        <h2>{text.femaTitle}</h2>
                        <p>{text.femaLead}</p>
                    </div>
                    <div className="grid four">
                        {femaPreparedness.map((group) => (
                            <div className="card" key={group.title}>
                                <h3>{group.title}</h3>
                                <div className="list">
                                    {group.items.map((item) => (
                                        <span key={item}>{item}</span>
                                    ))}
                                </div>
                            </div>
                        ))}
                    </div>
                    <p className="section-note">{text.femaNote1}</p>
                    <p className="section-note">{text.femaNote2}</p>
                </section>

                <section className="section" id="sobrevivencia">
                    <div className="section-title">
                        <h2>{text.survivalTitle}</h2>
                        <p>{text.survivalLead}</p>
                    </div>
                    <div className="grid two">
                        {survivalTopics.map((topic) => (
                            <div className="card" key={topic.title}>
                                <h3>{topic.title}</h3>
                                <div className="list">
                                    {topic.items.map((item) => (
                                        <span key={item}>{item}</span>
                                    ))}
                                </div>
                            </div>
                        ))}
                    </div>
                </section>

                <section className="section" id="seguranca">
                    <div className="section-title">
                        <h2>{text.safetyTitle}</h2>
                        <p>{text.safetyLead}</p>
                    </div>
                    <div className="card full">
                        <div className="list">
                            {text.safetyItems.map((item) => (
                                <span key={item}>{item}</span>
                            ))}
                        </div>
                    </div>
                </section>
            </div >
            <style jsx>{`
                :global(body) {
                    margin: 0;
                    font-family: "Space Grotesk", "Rubik", "Segoe UI", sans-serif;
                    background: #05070a;
                    color: #f4f6f8;
                }
                .page {
                    min-height: 100vh;
                    padding: 64px 7vw 120px;
                    background:
                        radial-gradient(circle at 10% 10%, rgba(0, 161, 241, 0.25), transparent 45%),
                        radial-gradient(circle at 90% 20%, rgba(240, 94, 60, 0.2), transparent 40%),
                        radial-gradient(circle at 20% 80%, rgba(85, 255, 175, 0.15), transparent 50%),
                        #05070a;
                }
                .language-bar {
                    display: flex;
                    justify-content: flex-end;
                    align-items: center;
                    gap: 16px;
                    margin-bottom: 24px;
                    flex-wrap: wrap;
                }
                .language-label {
                    display: inline-flex;
                    align-items: center;
                    gap: 8px;
                    font-size: 0.75rem;
                    text-transform: uppercase;
                    letter-spacing: 0.16em;
                    color: #7dcfff;
                }
                .language-label select {
                    padding: 8px 12px;
                    border-radius: 10px;
                    border: 1px solid rgba(255, 255, 255, 0.2);
                    background: rgba(12, 16, 22, 0.9);
                    color: #f4f6f8;
                    font-size: 0.85rem;
                }
                .language-note {
                    font-size: 0.8rem;
                    color: #b4bdc7;
                }
                .page[dir='rtl'] .language-bar {
                    justify-content: flex-start;
                }
                .page[dir='rtl'] .language-label {
                    flex-direction: row-reverse;
                }
                .hero {
                    display: grid;
                    grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
                    gap: 40px;
                    align-items: center;
                    margin-bottom: 80px;
                }
                .hero-copy h1 {
                    font-size: clamp(2.4rem, 3.6vw, 4rem);
                    margin: 12px 0 16px;
                    line-height: 1.05;
                }
                .lead {
                    font-size: 1.1rem;
                    color: #d2d7dd;
                    max-width: 560px;
                }
                .eyebrow {
                    text-transform: uppercase;
                    font-size: 0.8rem;
                    letter-spacing: 0.2em;
                    color: #7dcfff;
                    margin: 0;
                }
                .hero-actions {
                    display: flex;
                    gap: 16px;
                    margin: 24px 0;
                    flex-wrap: wrap;
                }
                .btn {
                    padding: 12px 20px;
                    border-radius: 999px;
                    text-decoration: none;
                    font-weight: 600;
                    border: 1px solid transparent;
                    transition: transform 0.2s ease, box-shadow 0.2s ease;
                }
                .btn.primary {
                    background: linear-gradient(120deg, #0ab6ff, #00dca5);
                    color: #02121b;
                }
                .btn.ghost {
                    border-color: rgba(255, 255, 255, 0.25);
                    color: #f4f6f8;
                    background: rgba(255, 255, 255, 0.05);
                }
                .btn:hover {
                    transform: translateY(-2px);
                    box-shadow: 0 12px 32px rgba(0, 0, 0, 0.35);
                }
                .badge-row {
                    display: flex;
                    flex-wrap: wrap;
                    gap: 10px;
                }
                .badge {
                    padding: 6px 12px;
                    border-radius: 999px;
                    background: rgba(255, 255, 255, 0.08);
                    font-size: 0.85rem;
                    border: 1px solid rgba(255, 255, 255, 0.15);
                }
                .hero-panel {
                    display: grid;
                    gap: 24px;
                    align-items: center;
                    justify-items: center;
                }
                .panel-card {
                    background: rgba(255, 255, 255, 0.04);
                    border-radius: 24px;
                    padding: 24px;
                    border: 1px solid rgba(255, 255, 255, 0.12);
                    width: 100%;
                    max-width: 360px;
                    box-shadow: 0 20px 50px rgba(0, 0, 0, 0.35);
                }
                .panel-title {
                    margin: 0 0 16px;
                    font-weight: 600;
                }
                .panel-grid {
                    display: grid;
                    grid-template-columns: repeat(2, minmax(0, 1fr));
                    gap: 12px;
                }
                .panel-label {
                    display: block;
                    font-size: 0.75rem;
                    color: #93a4b5;
                }
                .panel-value {
                    display: block;
                    font-size: 1rem;
                    font-weight: 600;
                }
                .panel-footer {
                    margin-top: 16px;
                    font-size: 0.85rem;
                    color: #b4bdc7;
                }
                .pulse-ring {
                    position: relative;
                    width: 160px;
                    height: 160px;
                    display: grid;
                    place-items: center;
                }
                .pulse-ring::before,
                .pulse-ring::after {
                    content: "";
                    position: absolute;
                    inset: 0;
                    border-radius: 50%;
                    border: 2px solid rgba(255, 82, 82, 0.4);
                    animation: pulse 2.2s infinite ease;
                }
                .pulse-ring::after {
                    animation-delay: 1.1s;
                }
                .pulse-core {
                    width: 96px;
                    height: 96px;
                    border-radius: 50%;
                    background: #ff4343;
                    display: grid;
                    place-items: center;
                    font-size: 1.4rem;
                    font-weight: 700;
                    box-shadow: 0 12px 30px rgba(255, 67, 67, 0.4);
                }
                .section {
                    margin: 80px 0;
                }
                .section-title h2 {
                    font-size: clamp(1.6rem, 2.2vw, 2.4rem);
                    margin-bottom: 12px;
                }
                .section-title p {
                    max-width: 720px;
                    color: #c2c9d1;
                }
                .grid {
                    display: grid;
                    gap: 20px;
                    margin-top: 24px;
                }
                .grid.two {
                    grid-template-columns: repeat(auto-fit, minmax(260px, 1fr));
                }
                .grid.three {
                    grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
                }
                .grid.four {
                    grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
                }
                .card {
                    background: rgba(255, 255, 255, 0.04);
                    border-radius: 20px;
                    padding: 20px;
                    border: 1px solid rgba(255, 255, 255, 0.12);
                    box-shadow: 0 20px 50px rgba(0, 0, 0, 0.25);
                    animation: rise 0.6s ease both;
                    animation-delay: var(--delay, 0s);
                }
                .card.full {
                    width: 100%;
                }
                .card h3 {
                    margin-top: 0;
                }
                .wizard label {
                    display: block;
                    margin-top: 16px;
                    font-size: 0.9rem;
                }
                .mesh-container {
                    display: grid;
                    grid-template-columns: 1fr 1fr;
                    gap: 30px;
                    margin-top: 30px;
                }
                .mesh-radar-view, .mesh-comms-view {
                    background: rgba(255, 255, 255, 0.03);
                    border: 1px solid rgba(255, 255, 255, 0.1);
                    border-radius: 24px;
                    padding: 24px;
                    display: flex;
                    flex-direction: column;
                }
                .radar-display {
                    flex: 1;
                    height: 300px;
                    background: #0a0e14;
                    border-radius: 20px;
                    position: relative;
                    overflow: hidden;
                    border: 1px solid rgba(0, 161, 241, 0.2);
                }
                .radar-grid {
                    width: 100%;
                    height: 100%;
                    position: relative;
                    background-image: 
                        radial-gradient(circle, rgba(0, 161, 241, 0.1) 1px, transparent 1px),
                        radial-gradient(circle, rgba(0, 161, 241, 0.05) 1px, transparent 1px);
                    background-size: 40px 40px, 80px 80px;
                }
                .radar-sweep {
                    position: absolute;
                    width: 100%;
                    height: 100%;
                    background: conic-gradient(from 0deg, rgba(0, 161, 241, 0.3) 0%, transparent 20%);
                    animation: sweep 4s linear infinite;
                    transform-origin: center;
                    border-radius: 50%;
                }
                @keyframes sweep {
                    from { transform: rotate(0deg); }
                    to { transform: rotate(360deg); }
                }
                .node-dot {
                    position: absolute;
                    width: 12px;
                    height: 12px;
                    background: #00ff00;
                    border-radius: 50%;
                    box-shadow: 0 0 10px #00ff00;
                    transform: translate(-50%, -50%);
                }
                .node-dot.server { background: #ff00ff; box-shadow: 0 0 10px #ff00ff; }
                .node-dot.wearable { background: #ffff00; box-shadow: 0 0 10px #ffff00; }
                .center-dot {
                    position: absolute;
                    left: 50%;
                    top: 50%;
                    width: 10px;
                    height: 10px;
                    background: #fff;
                    border-radius: 50%;
                    transform: translate(-50%, -50%);
                    font-size: 0.7rem;
                    text-align: center;
                    line-height: 25px;
                }
                .node-label {
                    position: absolute;
                    top: 15px;
                    left: 50%;
                    transform: translateX(-50%);
                    font-size: 0.7rem;
                    white-space: nowrap;
                    color: rgba(255, 255, 255, 0.6);
                }
                .comms-header {
                    margin-bottom: 20px;
                }
                .comms-main {
                    display: grid;
                    grid-template-columns: 200px 1fr;
                    gap: 20px;
                    flex: 1;
                    min-height: 400px;
                }
                .comms-sidebar {
                    border-right: 1px solid rgba(255, 255, 255, 0.1);
                    padding-right: 20px;
                    display: flex;
                    flex-direction: column;
                    gap: 30px;
                }
                .sidebar-section h4 {
                    font-size: 0.7rem;
                    text-transform: uppercase;
                    color: rgba(255, 255, 255, 0.4);
                    margin-bottom: 12px;
                    letter-spacing: 1px;
                }
                .room-list {
                    display: flex;
                    flex-direction: column;
                    gap: 6px;
                }
                .room-list button {
                    background: transparent;
                    border: none;
                    color: rgba(255, 255, 255, 0.7);
                    text-align: left;
                    padding: 8px 12px;
                    border-radius: 8px;
                    cursor: pointer;
                    font-size: 0.85rem;
                    transition: all 0.2s;
                }
                .room-list button:hover {
                    background: rgba(255, 255, 255, 0.05);
                    color: #fff;
                }
                .room-list button.active {
                    background: rgba(0, 161, 241, 0.15);
                    color: #00a1f1;
                    font-weight: 600;
                }
                .contact-list {
                    display: flex;
                    flex-direction: column;
                    gap: 12px;
                }
                .contact-item {
                    display: flex;
                    justify-content: space-between;
                    align-items: center;
                    font-size: 0.8rem;
                }
                .contact-name { color: rgba(255, 255, 255, 0.8); }
                .contact-dist { font-size: 0.7rem; color: rgba(255, 255, 255, 0.4); }
                .contact-item::before {
                    content: '';
                    width: 8px;
                    height: 8px;
                    border-radius: 50%;
                    margin-right: 8px;
                }
                .contact-item.online::before { background: #00ff00; box-shadow: 0 0 5px #00ff00; }
                .contact-item.away::before { background: #ffaa00; }
                .contact-item.offline::before { background: #555; }

                .comms-chat {
                    display: flex;
                    flex-direction: column;
                    background: rgba(0, 0, 0, 0.2);
                    border-radius: 16px;
                    padding: 16px;
                }
                .active-room-header {
                    font-weight: bold;
                    margin-bottom: 16px;
                    padding-bottom: 8px;
                    border-bottom: 1px solid rgba(255, 255, 255, 0.1);
                    color: #00a1f1;
                }
                .message-list {
                    flex: 1;
                    height: 300px;
                    overflow-y: auto;
                    display: flex;
                    flex-direction: column;
                    gap: 10px;
                    padding-right: 10px;
                }
                .message-item {
                    font-size: 0.85rem;
                    background: rgba(255, 255, 255, 0.04);
                    padding: 10px 14px;
                    border-radius: 12px;
                    border: 1px solid rgba(255, 255, 255, 0.05);
                }
                .msg-from { font-weight: bold; color: #7dd3ff; margin-right: 8px; }
                .msg-time { font-size: 0.7rem; color: rgba(255, 255, 255, 0.3); float: right; }
                .message-input {
                    margin-top: 20px;
                    display: flex;
                    gap: 12px;
                }
                .message-input input {
                    flex: 1;
                    background: rgba(255, 255, 255, 0.05);
                    border: 1px solid rgba(255, 255, 255, 0.1);
                    color: #fff;
                    padding: 12px 16px;
                    border-radius: 12px;
                    outline: none;
                    font-size: 0.9rem;
                    transition: border-color 0.2s;
                }
                .message-input input:focus {
                    border-color: #00a1f1;
                }
                .message-input button {
                    background: #00a1f1;
                    color: #fff;
                    border: none;
                    padding: 0 24px;
                    border-radius: 12px;
                    cursor: pointer;
                    font-weight: 600;
                    transition: background 0.2s;
                }
                .message-input button:hover {
                    background: #0081c1;
                }
                @media (max-width: 900px) {
                    .mesh-container { grid-template-columns: 1fr; }
                    .comms-main { grid-template-columns: 1fr; }
                    .comms-sidebar { border-right: none; border-bottom: 1px solid rgba(255, 255, 255, 0.1); padding-bottom: 20px; }
                }
                .radar-sweep {
                    position: absolute;
                    width: 100%;
                    height: 100%;
                    background: conic-gradient(from 0deg, rgba(0, 161, 241, 0.3) 0%, transparent 20%);
                    animation: sweep 4s linear infinite;
                    transform-origin: center;
                    border-radius: 50%;
                }
                .wizard select {
                    width: 100%;
                    margin-top: 6px;
                    padding: 10px;
                    border-radius: 12px;
                    border: 1px solid rgba(255, 255, 255, 0.2);
                    background: rgba(12, 16, 22, 0.9);
                    color: #f4f6f8;
                }
                .check-group {
                    margin-top: 16px;
                }
                .group-title {
                    margin: 0 0 8px;
                    font-size: 0.85rem;
                    color: #9fb2c6;
                }
                .checkbox {
                    display: flex;
                    align-items: center;
                    gap: 8px;
                    font-size: 0.9rem;
                    margin-bottom: 8px;
                }
                .api-box {
                    margin-top: 16px;
                    background: rgba(0, 0, 0, 0.3);
                    padding: 12px;
                    border-radius: 12px;
                    font-size: 0.8rem;
                }
                code {
                    display: block;
                    color: #9fffd1;
                    word-break: break-all;
                }
                .wizard-result .list span {
                    display: block;
                    margin-bottom: 8px;
                }
                .muted {
                    color: #a6b0bb;
                }
                .disclaimer {
                    margin-top: 16px;
                    font-size: 0.8rem;
                    color: #b38b8b;
                }
                .list span {
                    display: block;
                    padding: 6px 0;
                    border-bottom: 1px dashed rgba(255, 255, 255, 0.08);
                }
                .list span:last-child {
                    border-bottom: none;
                }
                .downloads {
                    display: grid;
                    gap: 20px;
                }
                .download-card {
                    background: rgba(255, 255, 255, 0.03);
                    border-radius: 20px;
                    padding: 20px;
                    border: 1px solid rgba(255, 255, 255, 0.12);
                    display: grid;
                    gap: 12px;
                }
                .download-head {
                    display: flex;
                    justify-content: space-between;
                    align-items: center;
                }
                .tag {
                    background: rgba(0, 161, 241, 0.2);
                    color: #7dd3ff;
                    padding: 4px 10px;
                    border-radius: 999px;
                    font-size: 0.75rem;
                }
                .download-links {
                    display: grid;
                    grid-template-columns: repeat(auto-fit, minmax(180px, 1fr));
                    gap: 10px;
                }
                .download-links a {
                    text-decoration: none;
                    padding: 10px 12px;
                    border-radius: 12px;
                    background: rgba(255, 255, 255, 0.05);
                    color: #e6f1ff;
                    border: 1px solid rgba(255, 255, 255, 0.1);
                    transition: transform 0.2s ease;
                }
                .download-links a:hover {
                    transform: translateY(-2px);
                }
                .download-note {
                    margin: 12px 0 0;
                    font-size: 0.85rem;
                    color: #a6b0bb;
                }
                .comms-block {
                    margin-top: 16px;
                }
                .phonetic-grid {
                    display: grid;
                    grid-template-columns: repeat(auto-fit, minmax(140px, 1fr));
                    gap: 10px;
                    margin-top: 16px;
                }
                .phonetic-item {
                    display: flex;
                    align-items: center;
                    justify-content: space-between;
                    padding: 8px 12px;
                    border-radius: 12px;
                    border: 1px solid rgba(255, 255, 255, 0.12);
                    background: rgba(255, 255, 255, 0.04);
                    font-size: 0.85rem;
                }
                .phonetic-letter {
                    font-weight: 700;
                    color: #7dd3ff;
                }
                .phonetic-code {
                    color: #e6f1ff;
                }
                .section-note {
                    margin-top: 12px;
                    font-size: 0.85rem;
                    color: #a6b0bb;
                }
                strong {
                    color: #f7f9fb;
                }
                @keyframes pulse {
                    0% { transform: scale(0.9); opacity: 0.5; }
                    60% { transform: scale(1.1); opacity: 0.1; }
                    100% { transform: scale(1.2); opacity: 0; }
                }
                @keyframes rise {
                    from { opacity: 0; transform: translateY(12px); }
                    to { opacity: 1; transform: translateY(0); }
                }
                @media (max-width: 720px) {
                    .page {
                        padding: 48px 6vw 100px;
                    }
                    .hero-actions {
                        flex-direction: column;
                        align-items: stretch;
                    }
                }
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
