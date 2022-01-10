#!/usr/bin/env bash

cd cardano-wallet

nix-build -A cardano-wallet -o build-wallet

./build-wallet/bin/cardano-wallet serve --testnet ../cardano-node/configuration/defaults/byron-testnet/genesis.json --port 38090 --node-socket ../cardano-node/state-node-testnet/node.socket
