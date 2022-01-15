#!/usr/bin/env nix-shell
#!nix-shell -i "make -f" -p gnumake jq curl


build-pab:
	nix-build marlowe-cardano/default.nix -A marlowe-pab -o build-pab

build-node:
	nix-build cardano-node/default.nix -A cardano-node -o build-node

build-cli:
	nix-build cardano-node/default.nix -A cardano-cli -o build-cli

build-wallet:
	nix-build cardano-wallet/default.nix -A cardano-wallet -o build-wallet

build-chain-index:
	nix-shell plutus-apps/shell.nix --run "cd plutus-apps; cabal install --installdir=../build-chain-index exe:plutus-chain-index"

build-run:
	nix-build marlowe-cardano/default.nix -A marlowe-dashboard.marlowe-run-backend-invoker -o build-run


run-node: build-node
	./build-node/bin/cardano-node run --config marlowe-cardano/bitte/node/config/config.json     \
	                                  --topology marlowe-cardano/bitte/node/config/topology.yaml \
	                                  --database-path node.db                                    \
	                                  --socket-path node.socket                                  \
	                                  --port 3001

run-wallet: build-wallet
	./build-wallet/bin/cardano-wallet serve --testnet marlowe-cardano/bitte/node/config/byron-genesis.json \
	                                        --database wallet.db                                           \
	                                        --node-socket node.socket                                      \
	                                        --port 8090

run-index: build-chain-index
	./build-chain-index/plutus-chain-index start-index --network-id 1564                  \
	                                                   --db-path chain-index.db/ci.sqlite \
	                                                   --socket-path node.socket          \
	                                                   --port 9083

clean-pab:
	-rm marlowe-pab.db

marlowe-pab.db: build-pab
	./build-pab/bin/marlowe-pab migrate --config marlowe-pab.yaml

run-pab: build-pab marlowe-pab.db
	./build-pab/bin/marlowe-pab webserver --config marlowe-pab.yaml                \
	                                      --passphrase fixme-allow-pass-per-wallet \
	                                      --verbose

run-server: build-run
	./build-run/bin/marlowe-dashboard-server webserver --config marlowe-run.json


run-client:
	nix-shell marlowe-cardano/shell.nix --run "cd marlowe-cardano/marlowe-dashboard-client; npm run start"


statistics:
	@du -hs node.db wallet.db chain-index.db marlowe-pab.db
	@curl -H 'accept: application/json;charset=utf-8' http://localhost:9083/tip


.PHONY: clean-pab run-node run-wallet run-chain-index run-pab run-server run-client
