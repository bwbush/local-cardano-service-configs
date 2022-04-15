#!/usr/bin/env nix-shell
#!nix-shell -i "make -f" -p gnumake jq curl postgresql


build-pab:
	nix-build marlowe-cardano/default.nix -A marlowe-pab -o build-pab

build-node:
	nix-build cardano-node/default.nix -A cardano-node -o build-node

build-cli:
	nix-build cardano-node/default.nix -A cardano-cli -o build-cli

build-wallet:
	nix-build cardano-wallet/default.nix -A cardano-wallet -o build-wallet

build-index:
	nix-shell plutus-apps/shell.nix --run "cd plutus-apps; cabal install --installdir=../build-index exe:plutus-chain-index"

build-run:
	nix-build marlowe-cardano/default.nix -A marlowe-dashboard.marlowe-run-backend-invoker -o build-run

build-db-sync:
	nix-build cardano-db-sync/default.nix -A cardano-db-sync -o build-db-sync


run-node: build-node
	./build-node/bin/cardano-node run --config cardano-node/configuration/cardano/testnet-config.json     \
	                                  --topology cardano-node/configuration/cardano/testnet-topology.json \
	                                  --database-path node.db                                             \
	                                  --socket-path node.socket                                           \
	                                  --port 33001

run-wallet: build-wallet
	./build-wallet/bin/cardano-wallet serve --testnet cardano-node/configuration/cardano/testnet-byron-genesis.json \
	                                        --database wallet.db                                                    \
	                                        --node-socket node.socket                                               \
	                                        --port 38090                                                            \
	                                        --log-level DEBUG

run-index: build-index
	./build-index/plutus-chain-index start-index --network-id 1097911063                  \
	                                                   --db-path chain-index.db/ci.sqlite \
	                                                   --socket-path node.socket          \
	                                                   --port 39083

run-db:
	PGHOST=/data/postgresql PGPASSFILE=cardano-db-sync/config/pgpass-testnet build-db-sync/bin/cardano-db-sync \
	    --config cardano-db-sync/config/testnet-config.yaml                                                    \
	    --socket-path node.socket                                                                              \
	    --state-dir db-sync.db                                                                                 \
	    --schema-dir cardano-db-sync/schema/

clean-pab:
	-rm marlowe-pab.db

marlowe-pab.db: build-pab
	./build-pab/bin/marlowe-pab migrate --config marlowe-pab.yaml

run-pab: build-pab marlowe-pab.db
	./build-pab/bin/marlowe-pab webserver --config marlowe-pab.yaml                \
	                                      --passphrase fixme-allow-pass-per-wallet \
	                                      --memory                                 \
	                                      --verbose

run-server: build-run
	./build-run/bin/marlowe-dashboard-server webserver --config marlowe-run.json


run-client:
	nix-shell marlowe-cardano/shell.nix --run "cd marlowe-cardano/marlowe-dashboard-client; spago build; npm run start"


statistics:
	@-du -hsc node.db wallet.db chain-index.db marlowe-pab.db
	@curl -H 'accept: application/json;charset=utf-8' http://localhost:39083/tip


.PHONY: clean-pab run-node run-wallet run-index run-pab run-server run-client
