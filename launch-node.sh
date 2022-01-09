#!/usr/bin/env bash

cd cardano-node

nix-build -A scripts.mainnet.node -o build-node-mainnet

./build-node-mainnet/bin/cardano-node-mainnet
