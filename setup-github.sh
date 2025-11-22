#!/bin/bash

# Script to create GitHub repository and push code
# Prerequisites: GitHub CLI (gh) must be installed and authenticated

echo "Creating GitHub repository 'Helloworld'..."
gh repo create Helloworld --public --source=. --remote=origin --push

echo "Repository created and code pushed successfully!"

