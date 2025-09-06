#!/bin/bash

# Update system and AUR packages
sudo pacman -Syu --noconfirm
yay -Syu --noconfirm

# Clean package cache
sudo paccache -r

# Remove orphaned packages
sudo pacman -Rns $(pacman -Qdtq) --noconfirm

# Clean journal logs older than 4 weeks
sudo journalctl --vacuum-time=4weeks

# Remove old kernel versions (keeping the current one)
sudo paccache -rk1
