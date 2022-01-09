#!/usr/bin/env bash

cd cardano-node

nix-build -A cardano-node -o build-node

cd ../node

../cardano-node/build-node/bin/cardano-node run --topology topology.yaml --database-path db --socket-path node.socket --config config.json  --port 43001
