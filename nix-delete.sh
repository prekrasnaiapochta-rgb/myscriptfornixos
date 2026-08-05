#!/usr/bin/env bash

PKG="$1"
CONFIG="/etc/nixos/configuration.nix" 
BACKUP="${CONFIG}.bak"

if [ -z "$PKG" ]; then
    echo "[-] Please specify a package to remove! Example: ./nix-delete.sh fastfetch"
    exit 1
fi


if [[ ! "$PKG" =~ ^[a-zA-Z0-9_-]+$ ]]; then
    echo "[-] Error: Invalid package name! Only letters, numbers, dashes, and underscores are allowed."
    exit 1
fi

echo "[*] Searching for package '$PKG' in configuration..."

if ! grep -qE "(\s|^)$PKG(\s|$)" "$CONFIG"; then
    echo "[-] Package '$PKG' is not found in your configuration."
    exit 1
fi

echo "[*] Backing up configuration to $BACKUP..."

sudo cp "$CONFIG" "$BACKUP"

echo "[*] Removing '$PKG' from the configuration..."

sudo sed -i "/^[ \t]*$PKG[ \t]*$/d" "$CONFIG"

echo "[*] Rebuilding NixOS..."
if BUILD_LOG=$(sudo nixos-rebuild switch 2>&1); then
    echo "[+] System successfully rebuilt! Package '$PKG' removed."
    sudo rm "$BACKUP"
else
    echo "[-] Rebuild failed! Restoring original configuration..."
    sudo mv "$BACKUP" "$CONFIG"
    echo "[-] Here is the error log:"
    echo "----------------------------------------"
    echo "$BUILD_LOG"
    echo "----------------------------------------"
    exit 1
fi
