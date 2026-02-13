import os
import json
import re

file_path = r'c:\site\mentalesaude\www\ricardo\sos\TECNOLOGIAS_MAPEAMENTO.md'
output_path = r'c:\site\mentalesaude\www\ricardo\sos\web\assets\data\tech_registry.json'

# Ensure directory exists
os.makedirs(os.path.dirname(output_path), exist_ok=True)

technologies = []

with open(file_path, 'r', encoding='utf-8') as f:
    lines = f.readlines()

for line in lines:
    line = line.strip()
    if not line.startswith('|') or '---|---' in line or 'Tecnologia' in line:
        continue
    
    parts = [p.strip() for p in line.split('|')]
    # | ID | Tech | Cat | Status | Plat | Ver |
    # parts[0] is empty, parts[1]=ID, parts[2]=Tech, etc.
    if len(parts) >= 7:
        tech = {
            "id": parts[1],
            "name": parts[2],
            "category": parts[3],
            "status": parts[4],
            "platforms": parts[5].split(','),
            "version": parts[6]
        }
        technologies.append(tech)

with open(output_path, 'w', encoding='utf-8') as f:
    json.dump(technologies, f, indent=2, ensure_ascii=False)

print(f"Exported {len(technologies)} technologies to JSON.")
