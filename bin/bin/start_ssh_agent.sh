#!/bin/bash

# Start SSH agent
eval "$(ssh-agent -s)"

# Add your private key to the agent
ssh-add ~/.ssh/id_ed25519

echo "SSH agent started and private key added."