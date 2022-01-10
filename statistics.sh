#!/usr/bin/env bash

echo
echo "Node database size:"
du -hs node/db

echo
echo "Chain index tip:"
du -h chain-index.sqlite

echo
echo "Chain index size:"
curl -H 'accept: application/json;charset=utf-8' http://localhost:49083/tip
echo
