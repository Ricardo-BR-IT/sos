import os

file_path = r'c:\site\mentalesaude\www\ricardo\sos\TECNOLOGIAS_MAPEAMENTO.md'

with open(file_path, 'r', encoding='utf-8') as f:
    lines = f.readlines()

new_lines = []
for line in lines:
    stripped = line.strip()
    if not stripped.startswith('|'):
        new_lines.append(line)
        continue

    # It's a table row
    if '---|---' in line:
        # Separator row. Ensure it has 6 columns.
        # Current: |---|---|---|---|---| (5 cols)
        # Target:  |---|---|---|---|---|---| (6 cols)
        if line.count('|') == 6: # 5 cols = 6 pipes
             new_lines.append(line.replace('|\n', '-|---|\n'))
        else:
             new_lines.append(line)
    elif ' Tecnologia ' in line:
        # Header row. Already updated in previous step?
        if 'Versão' not in line:
             new_lines.append(line.replace('|\n', ' Versão |\n'))
        else:
             new_lines.append(line)
    else:
        # Data row
        parts = [p.strip() for p in line.split('|')]
        # parts[0] is empty (before first pipe), parts[-1] is empty (after last pipe)
        # So for 5 columns, len(parts) should be 7.
        
        if len(parts) == 7: # 5 data columns
            # ID, Tech, Cat, Status, Plat
            # Add Version
            version = "v4.0.0"
            if "planning" in line.lower():
                version = "Planned"
            elif "partial" in line.lower():
                version = "v0.1.0"
            
            # Reconstruct line
            # parts[1]..parts[5] are the data.
            new_line = f"| {parts[1]} | {parts[2]} | {parts[3]} | {parts[4]} | {parts[5]} | {version} |\n"
            new_lines.append(new_line)
        else:
            new_lines.append(line)

with open(file_path, 'w', encoding='utf-8') as f:
    f.writelines(new_lines)

print("Table updated successfully with versions.")
