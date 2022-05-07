#!/usr/bin/env nix-shell
#!nix-shell -i "make -f" -p gnumake jq curl postgresql

SHELL=nix-shell
.SHELLFLAGS=marlowe-cardano/shell.nix --run


include configuration.env


marlowe-cardano:
	git clone git@github.com:input-output-hk/marlowe-cardano.git
	cd marlowe-cardano ; git apply ../marlowe-cardano.patch

iohk-nix:
	git clone git@github.com:input-output-hk/iohk-nix.git -b marlowe-dev-testnet

daedalus:
	git clone git@github.com:input-output-hk/daedalus.git -b feature/ddw-1039-marlowe-pioneers-installer
	cd daedalus ; git apply ../daedalus.patch

run-node: marlowe-cardano iohk-nix
	cardano-node run --config node.config      \
	                 --topology node.topology  \
	                 --database-path node.db   \
	                 --socket-path node.socket \
	                 --port $(CARDANO_NODE_PORT)

run-wallet: marlowe-cardano iohk-nix
	cardano-wallet serve --testnet iohk-nix/cardano-lib/marlowe-dev/byron-genesis.json \
	                     --database wallet.db                                          \
	                     --node-socket node.socket                                     \
	                     --port $(CARDANO_WALLET_PORT)                                 \
	                     --log-level DEBUG

chain-index.db:
	mkdir $@

run-index: chain-index.db marlowe-cardano iohk-nix
	plutus-chain-index start-index --network-id $(CARDANO_TESTNET_MAGIC) \
	                               --db-path chain-index.db/ci.sqlite    \
	                               --socket-path node.socket             \
	                               --port $(CARDANO_CHAIN_INDEX_PORT)

node.protocol: marlowe-cardano
	export CARDANO_NODE_SOCKET_PATH=$(CURDIR)/node.socket                        ; \
	cardano-cli query protocol-parameters --testnet-magic $(CARDANO_TESTNET_MAGIC) \
	                                      --out-file $@

run-pab: node.protocol marlowe-cardano iohk-nix
	marlowe-pab webserver --config marlowe-pab.yaml                \
	                      --memory                                 \
	                      --passphrase fixme-allow-pass-per-wallet

run-pab-verbose: marlowe-pab.db node.protocol marlowe-cardano iohk-nix
	marlowe-pab webserver --config marlowe-pab.yaml                \
	                      --memory                                 \
	                      --passphrase fixme-allow-pass-per-wallet \
	                      --verbose

test-nonpab: marlowe-cardano
	cd marlowe-cardano/marlowe-cli                        ; \
	export TREASURY=/extra/iohk/networks/treasury         ; \
	export CARDANO_NODE_SOCKET_PATH=$(CURDIR)/node.socket ; \
	export CARDANO_TESTNET_MAGIC=$(CARDANO_TESTNET_MAGIC) ; \
	./run-nonpab-tests.sh

test-pab: marlowe-cardano
	cd marlowe-cardano/marlowe-cli                           ; \
	export TREASURY=/extra/iohk/networks/treasury            ; \
	export CARDANO_NODE_SOCKET_PATH=$(CURDIR)/node.socket    ; \
	export CARDANO_TESTNET_MAGIC=$(CARDANO_TESTNET_MAGIC)    ; \
	./run-tests.sh --w http://localhost:$(CARDANO_WALLET_PORT) \
	                -p http://localhost:$(MARLOWE_PAB_PORT)

run-marlowe-server: marlowe-cardano
	$$(nix-build marlowe-cardano/default.nix -A marlowe.haskell.packages.marlowe-dashboard-server.components.exes.marlowe-dashboard-server --no-out-link)/bin/marlowe-dashboard-server \
	webserver --config marlowe-run.json             \
	          --network-id $(CARDANO_TESTNET_MAGIC) \
	          --port $(MARLOWE_RUN_SERVER)

run-marlowe-client: marlowe-cardano
	cd marlowe-cardano/marlowe-dashboard-client ; \
	spago build                                 ; \
	npm run start

run-playground-server: marlowe-cardano
	WEBGHC_URL=$(MARLOWE_PLAYGROUND_SERVER) $$(nix-build marlowe-cardano/default.nix -A marlowe-playground.server --no-out-link)/bin/marlowe-playground-server \
	webserver --port $(MARLOWE_PLAYGROUND_SERVER)

run-playground-client: marlowe-cardano
	cd marlowe-cardano/marlowe-playground-client; npm run start

run-daedalus: daedalus
	cd daedalus ; \
	NETWORK=marlowe_dev nix-shell shell.nix --argstr nodeImplementation cardano --argstr cluster marlowe_dev --command 'yarn start ; exit'


.SUFFIXES:

.PHONY: clean-pab run-node run-wallet run-index run-pab run-dashboard-server run-dashboard-client
