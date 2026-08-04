#!/usr/bin/env bash

PKG="$1"
CONFIG="/etc/nixos/configuration.nix" 

if [ -z "$PKG" ]; then
    echo "!!!!Please specify a package! Example: ./nix-add.sh fastfetch!!!!"
    exit 1
fi

echo "Searching and validating package '$PKG' in nixpkgs..."

if ! nix-instantiate --eval --expr "with import <nixpkgs> {}; (builtins.tryEval pkgs.$PKG).success" | grep -q "true"; then
    echo "!!!!Error: Package '$PKG' does not exist, was removed, or is broken in nixpkgs!!!!"
    exit 1
fi

echo "Package '$PKG' is valid and available"

if grep -qE "(\s|^)$PKG(\s|$)" "$CONFIG"; then
    echo "!package '$PKG' is already in your configuration!"
    exit 0
fi

echo "Adding '$PKG' to the configuration..."
sudo sed -i "/# AUTO-PACKAGES/a \ \ \ \ $PKG" "$CONFIG"

echo "rebuilding NixOS..."

if BUILD_LOG=$(sudo nixos-rebuild switch 2>&1); then
    echo "{*}System successfully rebuilt and package installed!"
else
    echo "!!! Rebuild failed! Here is the error log:"
    echo "----------------------------------------"
    echo "$BUILD_LOG"
    echo "----------------------------------------"
    exit 1
fi
