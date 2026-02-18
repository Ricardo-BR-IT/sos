
// PREP MODULE (V8)
// Handles Checklists and Calculators

const bobItems = [
    "Water (3 Liters)",
    "Water Filter (Sawyer/Lifestraw)",
    "Food (3000 Calories - MREs/Bars)",
    "Knife (Full Tang)",
    "Fire Starter (Ferro Rod + Lighter)",
    "First Aid Kit (Trauma + Meds)",
    "Flashlight (Headlamp + Spare Batteries)",
    "Radio (Baofeng UV-5R or Similar)",
    "Shelter (Tarp/Bivvy)",
    "Paracord (50ft)",
    "Duct Tape",
    "Cash (Small Bills)",
    "Documents (ID, Map, USB Drive)"
];

export function initPrep() {
    renderChecklist();

    // Attach Calculator
    window.calculateRations = calculateRations;
}

function renderChecklist() {
    const list = document.getElementById('bob-list');
    if (!list) return;

    // Load saved state
    const saved = JSON.parse(localStorage.getItem('sos_prep_bob') || '{}');

    list.innerHTML = '';
    bobItems.forEach((item, index) => {
        const div = document.createElement('div');
        div.className = 'checklist-item';

        const checkbox = document.createElement('input');
        checkbox.type = 'checkbox';
        checkbox.checked = !!saved[index];
        checkbox.onchange = () => {
            saved[index] = checkbox.checked;
            localStorage.setItem('sos_prep_bob', JSON.stringify(saved));
        };

        const label = document.createElement('span');
        label.innerText = item;

        div.appendChild(checkbox);
        div.appendChild(label);
        list.appendChild(div);
    });
}

function calculateRations() {
    const people = parseInt(document.getElementById('calc-people').value) || 1;
    const days = parseInt(document.getElementById('calc-days').value) || 1;

    const water = people * days * 3; // 3 Liters per person/day
    const cals = people * days * 2000; // 2000 Calories baseline

    const res = document.getElementById('calc-result');
    res.style.display = 'block';
    res.innerHTML = `
        <strong>REQUIREMENTS:</strong><br>
        WATER: <span style="color:#0ff; font-size:1.2rem;">${water} Liters</span><br>
        FODD: <span style="color:#0ff; font-size:1.2rem;">${cals} Calories</span>
    `;
}

// Auto Init
document.addEventListener('DOMContentLoaded', initPrep);
