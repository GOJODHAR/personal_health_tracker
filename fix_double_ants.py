import os

directory = 'lib'

for root, _, files in os.walk(directory):
    for file in files:
        if file.endswith(".dart"):
            filepath = os.path.join(root, file)
            with open(filepath, 'r', encoding='utf-8') as f:
                content = f.read()

            content = content.replace('constconstants', 'constants')
            content = content.replace('AppConstConstants', 'AppConstants')
            
            with open(filepath, 'w', encoding='utf-8') as f:
                f.write(content)

print("Double consts squashed!")
