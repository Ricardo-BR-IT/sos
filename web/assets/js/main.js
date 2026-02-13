
document.addEventListener('DOMContentLoaded', () => {
    fetchTechData();
    setupSmoothScroll();
});

async function fetchTechData() {
    try {
        const response = await fetch('web/assets/data/tech_registry.json');
        const data = await response.json();
        renderTable(data);
        updateStats(data);
    } catch (error) {
        console.error('Error loading tech data:', error);
        document.getElementById('tech-table-body').innerHTML = '<tr><td colspan="6" class="text-center text-red">Error loading data. Please try again.</td></tr>';
    }
}

function renderTable(data) {
    const tbody = document.getElementById('tech-table-body');
    if (!tbody) return;

    tbody.innerHTML = '';

    data.forEach(tech => {
        const row = document.createElement('tr');

        // ID handling (make it code-like)
        const idCell = `<code>${tech.id}</code>`;

        // Check for platforms
        const hasMobile = tech.platforms.some(p => p.includes('mobile'));
        const hasDesktop = tech.platforms.some(p => p.includes('desktop'));
        const hasWeb = tech.platforms.some(p => p.includes('web'));
        const hasServer = tech.platforms.some(p => p.includes('server'));
        const hasJava = tech.platforms.some(p => p.includes('java'));

        const checkInfo = '<span class="status-supported">✓</span>';
        const crossInfo = '<span style="opacity:0.1">-</span>';

        row.innerHTML = `
            <td>${idCell}</td>
            <td><strong>${tech.name}</strong></td>
            <td><small>${tech.category}</small></td>
            <td class="text-center">${hasMobile ? checkInfo : crossInfo}</td>
            <td class="text-center">${hasDesktop ? checkInfo : crossInfo}</td>
            <td class="text-center">${hasWeb ? checkInfo : crossInfo}</td>
            <td class="text-center">${hasServer ? checkInfo : crossInfo}</td>
            <td class="text-center">${hasJava ? checkInfo : crossInfo}</td>
        `;
        tbody.appendChild(row);
    });
}

function updateStats(data) {
    const totalCount = data.length;
    const supportedCount = data.filter(t => t.status === 'supported').length;

    const countEl = document.getElementById('stat-total-techs');
    if (countEl) countEl.innerText = totalCount;

    const supportedEl = document.getElementById('stat-supported');
    if (supportedEl) supportedEl.innerText = `${Math.round((supportedCount / totalCount) * 100)}%`;
}

function setupSmoothScroll() {
    document.querySelectorAll('a[href^="#"]').forEach(anchor => {
        anchor.addEventListener('click', function (e) {
            e.preventDefault();
            document.querySelector(this.getAttribute('href')).scrollIntoView({
                behavior: 'smooth'
            });
        });
    });
}
