#!/usr/bin/env python3
# Fix pom.xml - Replace <n> tag with <name>

import re

with open('pom.xml', 'r', encoding='utf-8') as f:
    content = f.read()

# Replace <n> with <name> and </n> with </name> around HelloWorld
content = re.sub(r'<n>HelloWorld</n>', '<name>HelloWorld</name>', content)

with open('pom.xml', 'w', encoding='utf-8', newline='') as f:
    f.write(content)

print("pom.xml fixed successfully!")
print("Verification:", '<name>HelloWorld</name>' in content)
