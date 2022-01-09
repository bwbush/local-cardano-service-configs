#!/usr/bin/env bash

echo
echo "Node database size:"
du -hs cardano-node/state-node-testnet/db-testnet/

echo
echo "Chain index tip:"
du -h plutus-apps/plutus-pab/test-node/testnet/chain-index.db

echo
echo "Chain index size:"
curl -H 'accept: application/json;charset=utf-8' http://localhost:39084/tip
echo
