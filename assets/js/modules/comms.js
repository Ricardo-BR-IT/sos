
// COMMS MODULE (V7.1)
// Handles secure text messaging between nodes

import { log } from './ui.js';

const MSG_API = 'api/messages.php';
let myId = localStorage.getItem('v7_node_id');
let knownData = new Set(); // Stores MSG IDs to prevent duplicates
let chatBox;

export function initComms() {
    log("Initializing Comms Subsystem...");

    chatBox = document.getElementById('chat-box');
    const sendBtn = document.getElementById('send-btn');
    const msgInput = document.getElementById('msg-input');
    const targetSel = document.getElementById('msg-target');

    if (sendBtn && msgInput) {
        const sendAction = () => {
            let target = targetSel ? targetSel.value : 'PUBLIC';
            sendMessage(msgInput.value, target);
            msgInput.value = '';
        };

        sendBtn.addEventListener('click', sendAction);
        msgInput.addEventListener('keypress', (e) => {
            if (e.key === 'Enter') sendAction();
        });
    }

    // Poll for messages every 5s
    setInterval(fetchMessages, 5000);

    // Initial Fetch
    fetchMessages();
}

export async function sendMessage(content, channel = 'PUBLIC') {
    if (!content.trim()) return;

    try {
        const payload = {
            sender_id: myId,
            channel: channel,
            content: content
        };

        const res = await fetch(MSG_API, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(payload)
        });

        if (res.ok) {
            log(`[COMMS] Sent to ${channel}`);
            fetchMessages(); // Immediate refresh
        } else {
            log(`[ERROR] Send Failed: ${res.status}`);
        }

    } catch (e) {
        log(`[ERROR] Comms Error: ${e.message}`);
    }
}

async function fetchMessages() {
    try {
        // V7.2: No timestamp filter, just get latest
        const url = `${MSG_API}?my_id=${encodeURIComponent(myId)}`;

        const res = await fetch(url);
        if (res.ok) {
            const data = await res.json();
            if (data.messages && data.messages.length > 0) {
                processMessages(data.messages);
            }
        }
    } catch (e) {
        // Silent fail
    }
}

function processMessages(msgs) {
    if (!chatBox) return;

    msgs.forEach(msg => {
        // Unique ID check
        const sig = `${msg.sender_id}_${msg.timestamp}_${msg.content}`;

        if (!knownData.has(sig)) {
            knownData.add(sig);

            // Render
            const div = document.createElement('div');
            div.className = 'msg-line';
            const isMe = msg.sender_id === myId;
            const isPrivate = msg.channel !== 'PUBLIC';

            // 1. Render Original Content First
            let contentHtml = msg.content;

            // 2. Translation Hook
            const toggle = document.getElementById('translate-toggle');
            if (!isMe && toggle && toggle.checked) {
                // Async Translation
                translateText(msg.content).then(translated => {
                    if (translated) {
                        div.querySelector('.msg-content').innerHTML = `<span style="color:var(--neon-green)">[TR]</span> ${translated}`;
                    }
                });
            }

            if (isPrivate) {
                div.style.color = '#0ff';
                div.innerHTML = `<span style="opacity:0.6">[${msg.timestamp.split(' ')[1]}]</span> <b>${isMe ? 'TO ' + msg.channel : 'FROM ' + msg.sender_id}:</b> <span class="msg-content">${contentHtml}</span>`;
            } else {
                div.style.color = isMe ? '#0f0' : '#ccc';
                div.innerHTML = `<span style="opacity:0.6">[${msg.timestamp.split(' ')[1]}]</span> <b>${msg.sender_id}:</b> <span class="msg-content">${contentHtml}</span>`;
            }

            chatBox.appendChild(div);
            chatBox.scrollTop = chatBox.scrollHeight;
        }
    });
}

// V10: Translation Engine (MyMemory API)
// Rates: Free = 5000 chars/day
let myLang = navigator.language || 'en-US';

async function translateText(text) {
    try {
        const source = 'AUTODETECT';
        const target = myLang;
        const url = `https://api.mymemory.translated.net/get?q=${encodeURIComponent(text)}&langpair=${source}|${target}`;

        const res = await fetch(url);
        const data = await res.json();

        if (data.responseData && data.responseData.translatedText) {
            return data.responseData.translatedText;
        }
    } catch (e) {
        console.error("Translation Error:", e);
    }
    return null;
}
