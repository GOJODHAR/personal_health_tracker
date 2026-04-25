import os

directory = 'lib'

for root, _, files in os.walk(directory):
    for file in files:
        if file.endswith(".dart"):
            filepath = os.path.join(root, file)
            with open(filepath, 'r', encoding='utf-8') as f:
                content = f.read()

            # Reverse the horrific PowerShell replacements
            content = content.replace('Appants', 'AppConstants')
            content = content.replace('ants.dart', 'constants.dart')
            content = content.replace('Boxraints', 'BoxConstraints')
            content = content.replace('ructor', 'constructor')
            content = content.replace('raints', 'constraints')
            
            # Also clean up any lingering const issues where Theme.of(context) lives
            lines = content.split('\n')
            for i in range(len(lines)):
                if 'Theme.of(context)' in lines[i] and 'const ' in lines[i]:
                    lines[i] = lines[i].replace('const ', '')
                    
            content = '\n'.join(lines)
            
            with open(filepath, 'w', encoding='utf-8') as f:
                f.write(content)

print("Ants squashed and const fixed!")
