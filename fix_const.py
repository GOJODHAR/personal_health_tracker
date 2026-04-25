import os

directory = 'lib/screens'

for root, _, files in os.walk(directory):
    for file in files:
        if file.endswith(".dart"):
            filepath = os.path.join(root, file)
            with open(filepath, 'r', encoding='utf-8') as f:
                content = f.read()

            lines = content.split('\n')
            for i in range(len(lines)):
                # If Theme.of(context) is in the line, and const is present, remove const
                # This fixes "const Icon(..., color: Theme.of(context)...)" and "const Text(...)"
                if 'Theme.of(context)' in lines[i] and 'const ' in lines[i]:
                    lines[i] = lines[i].replace('const ', '')
                    
            content = '\n'.join(lines)
            
            with open(filepath, 'w', encoding='utf-8') as f:
                f.write(content)

print("Const fixes applied!")
