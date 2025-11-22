#!/bin/bash
# Fix pom.xml - Replace <n> tag with <name>
sed -i 's/<n>/<name>/g; s/<\/n>/<\/name>/g' pom.xml
echo "pom.xml fixed successfully!"

