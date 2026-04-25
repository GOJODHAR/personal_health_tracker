import os
import re

def fix_dark_mode(directory):
    for root, _, files in os.walk(directory):
        for file in files:
            if file.endswith(".dart"):
                filepath = os.path.join(root, file)
                with open(filepath, 'r', encoding='utf-8') as f:
                    content = f.read()

                # Fix Scaffold background
                content = re.sub(r'backgroundColor:\s*AppConstants\.backgroundColor', 'backgroundColor: Theme.of(context).scaffoldBackgroundColor', content)
                
                # Fix dark text
                content = re.sub(r'AppConstants\.textDark', '(Theme.of(context).brightness == Brightness.dark ? Colors.white : AppConstants.textDark)', content)
                
                # Fix medium text
                content = re.sub(r'AppConstants\.textMedium', '(Theme.of(context).brightness == Brightness.dark ? Colors.white70 : AppConstants.textMedium)', content)
                
                # Fix light text (when in dark mode, light text might need to stay light, so ignore)
                
                # Fix white backgrounds commonly used in containers
                # Find exactly:   color: Colors.white,
                # Mostly inside box decorations. We can safely replace this with cardColor ONLY if it's the container's background.
                # A safer approach: look for 'color: Colors.white,\n' with leading spaces, but it's risky for text.
                # Let's try replacing BoxDecoration(color: Colors.white...)
                content = re.sub(r'decoration:\s*BoxDecoration\(\s*color:\s*Colors\.white', 'decoration: BoxDecoration(color: Theme.of(context).cardColor', content)
                
                # Also try replacing container color directly if it looks like a background
                # (e.g., inside Container(...) if color is the first arg, but often it's in BoxDecoration)
                content = re.sub(r'fillColor:\s*Colors\.white', 'fillColor: Theme.of(context).cardColor', content)

                with open(filepath, 'w', encoding='utf-8') as f:
                    f.write(content)

fix_dark_mode('lib/screens')
print("Dark Mode fixes applied!")
