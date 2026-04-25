import re

files = [
    "lib/screens/add_health_data_screen.dart",
    "lib/screens/goals_screen.dart",
    "lib/screens/history_screen.dart",
    "lib/screens/login_screen.dart",
    "lib/screens/profile_screen.dart",
    "lib/screens/signup_screen.dart"
]

for file in files:
    with open(file, 'r', encoding='utf-8') as f:
        content = f.read()

    content = re.sub(r'([A-Z][a-zA-Z0-9]+)\(\{super\.key\}\)', r'const \1({super.key})', content)
    content = re.sub(r'([A-Z][a-zA-Z0-9]+)\(\{Key\? key\}\)', r'const \1({Key? key})', content)

    with open(file, 'w', encoding='utf-8') as f:
        f.write(content)

print("Constructors fixed!")
