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

build-playground:
	nix-build marlowe-cardano/default.nix -A marlowe-playground.server -o build-playground


run-node: build-node
	./build-node/bin/cardano-node run --config node.config      \
	                                  --topology node.topology  \
	                                  --database-path node.db   \
	                                  --socket-path node.socket \
	                                  --port 3001

run-wallet: build-wallet
	./build-wallet/bin/cardano-wallet serve --testnet iohk-nix/cardano-lib/marlowe-dev/byron-genesis.json \
	                                        --database wallet.db                                          \
	                                        --node-socket node.socket                                     \
	                                        --port 8090                                                   \
	                                        --log-level DEBUG

run-index: build-index
	./build-index/plutus-chain-index start-index --network-id 1566                  \
	                                             --db-path chain-index.db/ci.sqlite \
	                                             --socket-path node.socket          \
	                                             --port 9083

clean-pab:
	-rm marlowe-pab.db

marlowe-pab.db: build-pab
	./build-pab/bin/marlowe-pab migrate --config marlowe-pab.yaml

run-pab: build-pab marlowe-pab.db
	./build-pab/bin/marlowe-pab webserver --config marlowe-pab.yaml                \
	                                      --memory                                 \
	                                      --passphrase fixme-allow-pass-per-wallet

run-pab-verbose: build-pab marlowe-pab.db
	./build-pab/bin/marlowe-pab webserver --config marlowe-pab.yaml                \
	                                      --memory                                 \
	                                      --passphrase fixme-allow-pass-per-wallet \
	                                      --verbose
run-dashboard-server: build-run
	./build-run/bin/marlowe-dashboard-server webserver --config marlowe-run.json \
	                                                   --network-id 1566         \
                                                           --port 8083

run-dashboard-client:
	nix-shell marlowe-cardano/shell.nix --run "cd marlowe-cardano/marlowe-dashboard-client; spago build; npm run start"

run-playground-server: build-playground
	WEBGHC_URL=8083 ./build-playground/bin/marlowe-playground-server webserver --port 8083

run-playground-client:
	# cd marlowe-playground-client
	# $(nix-build ../default.nix -A marlowe-playground.generate-purescript)/bin/marlowe-playground-generate-purs
	# npm install
	# npm run build:spago
	# npm run build:webpack:dev:vendor
	nix-shell marlowe-cardano/shell.nix --command 'cd marlowe-cardano/marlowe-playground-client; npm run build:webpack:dev'


.PHONY: clean-pab run-node run-wallet run-index run-pab run-dashboard-server run-dashboard-client
