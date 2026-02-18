// UI Module
export function initUI() {
    // Clock
    setInterval(() => {
        document.getElementById('clock').innerText = new Date().toLocaleTimeString();
    }, 1000);

    // Initial Log
    log("UI Subsystem Loaded.");
}

export function log(msg) {
    const box = document.getElementById('system-log');
    if (!box) return;
    const line = document.createElement('div');
    const time = new Date().toLocaleTimeString();
    line.innerText = `> [${time}] ${msg}`;
    line.style.borderBottom = '1px solid #002200';
    box.appendChild(line);
    box.scrollTop = box.scrollHeight;
}

export function updateNodeList(nodes) {
    const list = document.getElementById('node-list');
    list.innerHTML = '';

    if (nodes.length === 0) {
        list.innerHTML = '<div style="color:#666; padding:10px;">NO SIGNAL</div>';
        return;
    }

    nodes.forEach(node => {
        const div = document.createElement('div');
        div.style.padding = '8px';
        div.style.borderBottom = '1px solid #004400';
        div.style.marginBottom = '4px';
        div.style.background = 'rgba(0,40,0,0.3)';

        div.innerHTML = `
            <div style="font-weight:bold; color:#0f0;">${node.name || node.id}</div>
            <div style="font-size:0.75rem; display:flex; justify-content:space-between;">
                <span>${node.type}</span>
                <span>BAT: ${node.battery}%</span>
            </div>
        `;
        list.appendChild(div);
    });
}
