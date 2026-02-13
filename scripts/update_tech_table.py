
import os

file_path = r'c:\site\mentalesaude\www\ricardo\sos\TECNOLOGIAS_MAPEAMENTO.md'

with open(file_path, 'r', encoding='utf-8') as f:
    lines = f.readlines()

new_lines = []
for line in lines:
    stripped = line.strip()
    if stripped.startswith('|') and '---|---' in stripped:
        # Separator line
        new_lines.append(line.replace('---|---|---|---|---|', '---|---|---|---|---|---|'))
    elif stripped.startswith('| ID |'):
        # Header line - already updated manually in previous step, but let's ensure
        if 'Versão' not in line:
             new_lines.append(line.replace('| Plataformas |', '| Plataformas | Versão |'))
        else:
             new_lines.append(line)
    elif stripped.startswith('|') and stripped.endswith('|'):
        # Data line
        # Check if it already has the version column (count pipes)
        pipes = line.count('|')
        if pipes == 6: # Standard 5 columns + 2 outer pipes = 7 pipes normally. Wait. 
                       # | ID | Tech | Cat | Status | Plat | -> 6 pipes.
                       # If we want 6 columns: | ID | Tech | Cat | Status | Plat | Ver | -> 7 pipes.
            
            # Implementation status logic
            version = "v0.2.0"
            
            if "planning" in line:
                version = "Planned"
            elif "partial" in line:
                version = "v0.1.0-alpha"
            
            new_lines.append(line.replace(' |', f' | {version} |', 1).replace('| \n', '|\n')) 
            # Actually simplest way is to replace the last | with | version |
            
            parts = [p.strip() for p in stripped.split('|') if p]
            if len(parts) == 5:
               new_line = f"| {parts[0]} | {parts[1]} | {parts[2]} | {parts[3]} | {parts[4]} | {version} |\n"
               new_lines.append(new_line)
            else:
               new_lines.append(line)
        else:
            new_lines.append(line)
    else:
        new_lines.append(line)

with open(file_path, 'w', encoding='utf-8') as f:
    f.writelines(new_lines)

print("Table updated successfully.")
