#!/bin/bash

# Exit if any command fails
set -e

# Configure Git user information
read -p "Enter your Git username: " git_username
git config --global user.name "$git_username"

read -p "Enter your Git email: " git_email
git config --global user.email "$git_email"

git config --global init.defaultBranch main

echo "Git setup complete!"