#!/bin/bash

echo -e "\033[0;32mDeploying updates to Firebase...\033[0m"

# Remove existing public folder
rm -rf public

# Build the project.
hugo --quiet

# Launch deployment
firebase deploy

echo -e "\033[0;32mDeploying done!\033[0m"
