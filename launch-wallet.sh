#!/usr/bin/env bash

cd cardano-wallet

nix-build -A cardano-wallet -o build-wallet

./build-wallet/bin/cardano-wallet serve --testnet ../node/byron-genesis.json --port 48090 --node-socket ../node/node.socket
