#!/usr/bin/env nix-shell
#!nix-shell -i bash -p postgresql

####cat << EOI > config/pgpass-testnet
####/data/postgresql:5432:testnet:cardano:*
####EOI
####chmod 0600 config/pgpass-testnet
####
####psql -c 'ALTER USER cardano CREATEDB;'
####
####PGPASSFILE=config/pgpass-testnet scripts/postgresql-setup.sh --createdb

PGHOST=/data/postgresql

cd cardano-db-sync

nix-build -A cardano-db-sync -o build-db-sync

PGPASSFILE=config/pgpass-testnet build-db-sync/bin/cardano-db-sync \
    --config config/testnet-config.yaml \
    --socket-path ../cardano-node/state-node-testnet/node.socket \
    --state-dir ledger-state/testnet \
    --schema-dir schema/
