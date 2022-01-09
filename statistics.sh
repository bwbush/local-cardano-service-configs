#!/usr/bin/env bash

echo
echo "Node database size:"
du -hs cardano-node/state-node-mainnet/db-mainnet/

echo
echo "Chain index tip:"
du -h plutus-apps/plutus-pab/test-node/mainnet/chain-index.db

echo
echo "Chain index size:"
curl -H 'accept: application/json;charset=utf-8' http://localhost:29084/tip
echo
