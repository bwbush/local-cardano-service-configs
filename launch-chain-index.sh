#!/usr/bin/env nix-shell
#!nix-shell -i bash plutus-apps/shell.nix

cd plutus-apps

cabal install --installdir=build-chain-index exe:plutus-chain-index

cd plutus-pab

../build-chain-index/plutus-chain-index start-index --network-id 1564 --db-path ../../chain-index.sqlite --port 49083 --socket-path ../../node/node.socket
