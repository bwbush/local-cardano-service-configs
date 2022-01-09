#!/usr/bin/env bash

cd cardano-node

nix-build -A scripts.testnet.node -o build-node-testnet

./build-node-testnet/bin/cardano-node-testnet
