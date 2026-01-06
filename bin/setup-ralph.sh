#!/bin/bash

# Create plans directory if it doesn't exist
mkdir -p plans

# Create plans/prd.json
touch plans/prd.json

# Create progress.txt
touch progress.txt

# Copy example PRD
cp ~/.dotfiles/plan/example-prd.json plans/example-prd.json
