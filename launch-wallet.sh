#!/usr/bin/env bash

cd cardano-wallet

nix-build -A cardano-wallet -o build-wallet

./build-wallet/bin/cardano-wallet serve --mainnet --port 28080 --node-socket ../cardano-node/state-node-mainnet/node.socket
