#!/usr/bin/env nix-shell
#!nix-shell -i bash plutus-apps/shell.nix

cd plutus-apps

cabal install --installdir=build-chain-index exe:plutus-chain-index

cd plutus-pab

../build-chain-index/plutus-chain-index --config test-node/testnet/chain-index-config.json start-index
