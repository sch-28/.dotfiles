#!/bin/bash

# Go to dotfiles root (optional, in case it's run from elsewhere)
cd "$(dirname "$0")"

# Get all folders except 'ly'
for dir in */; do
    dir=${dir%/}
    if [[ "$dir" != "ly" ]]; then
        stow "$dir"
    fi
done

# Now stow ly with sudo to /etc
echo "Stowing ly to /etc with sudo..."
sudo stow -t / ly
