#!/usr/bin/env python3
# Fix pom.xml - Replace <n> tag with <name>

with open('pom.xml', 'r', encoding='utf-8') as f:
    lines = f.readlines()

# Fix line 18 (index 17)
for i, line in enumerate(lines):
    if 'HelloWorld' in line and '<n>' in line:
        lines[i] = line.replace('<n>', '<name>').replace('</n>', '</name>')
        print(f"Fixed line {i+1}: {lines[i].strip()}")

with open('pom.xml', 'w', encoding='utf-8', newline='') as f:
    f.writelines(lines)

print("pom.xml fixed successfully!")

