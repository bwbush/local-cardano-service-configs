#!/usr/bin/env bash

cd cardano-wallet

nix-build -A cardano-wallet -o build-wallet

./build-wallet/bin/cardano-wallet serve --mainnet --port 38080 --node-socket ../cardano-node/state-node-testnet/node.socket
