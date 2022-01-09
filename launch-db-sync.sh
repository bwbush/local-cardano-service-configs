#!/usr/bin/env nix-shell
#!nix-shell -i bash -p postgresql

####cat << EOI > config/pgpass-mainnet
####/data/postgresql:5432:mainnet:cardano:*
####EOI
####chmod 0600 config/pgpass-mainnet
####
####psql -c 'ALTER USER cardano CREATEDB;'
####
####PGPASSFILE=config/pgpass-mainnet scripts/postgresql-setup.sh --createdb

PGHOST=/data/postgresql

cd cardano-db-sync

nix-build -A cardano-db-sync -o build-db-sync

PGPASSFILE=config/pgpass-mainnet build-db-sync/bin/cardano-db-sync \
    --config config/mainnet-config.yaml \
    --socket-path ../cardano-node/state-node-mainnet/node.socket \
    --state-dir ledger-state/mainnet \
    --schema-dir schema/
