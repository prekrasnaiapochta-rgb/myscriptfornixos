#!/usr/bin/env bash

CODE="$1"
CONFIG="/etc/nixos/configuration.nix" 
BACKUP="${CONFIG}.bak"

if [ -z "$CODE" ]; then
    echo "[-] Please specify the code to add!"
    echo "    Example: ./nix-add-code.sh 'services.openssh.enable = true;'"
    exit 1
fi

echo "[*] Checking if marker #Q!W!E!R exists..."

if ! grep -q "#Q!W!E!R" "$CONFIG"; then
    echo "[-] Error: Marker #Q!W!E!R not found in your configuration!"
    exit 1
fi

echo "[*] Validating input..."

if grep -qF "$CODE" "$CONFIG"; then
    echo "[!] This code is already in your configuration."
    exit 0
fi

echo "[*] Backing up configuration to $BACKUP..."

sudo cp "$CONFIG" "$BACKUP"

echo "[*] Adding code to the configuration..."

sudo sed -i '/#Q!W!E!R/a \ \ \ \ '"$CODE" "$CONFIG"

echo "[*] Rebuilding NixOS..."

if BUILD_LOG=$(sudo nixos-rebuild switch 2>&1); then
    echo "[+] System successfully rebuilt! Code added."

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
