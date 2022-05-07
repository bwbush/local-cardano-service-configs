#!/usr/bin/env nix-shell
#!nix-shell -i "make -f" -p gnumake jq curl postgresql

SHELL=nix-shell
.SHELLFLAGS=marlowe-cardano/shell.nix --run


include configuration.env


marlowe-cardano:
	git clone git@github.com:input-output-hk/marlowe-cardano.git

run-node: marlowe-cardano
	cardano-node run --config cardano-node/configuration/cardano/mainnet-config.json     \
	                 --topology cardano-node/configuration/cardano/mainnet-topology.json \
	                 --database-path node.db                                             \
	                 --socket-path node.socket                                           \
	                 --port $(CARDANO_NODE_PORT)

chain-index.db:
	mkdir $@

run-index: chain-index.db marlowe-cardano
	plutus-chain-index start-index --network-id $(CARDANO_TESTNET_MAGIC) \
	                               --db-path chain-index.db/ci.sqlite    \
	                               --socket-path node.socket             \
	                               --port $(CARDANO_CHAIN_INDEX_PORT)

node.protocol: marlowe-cardano
	export CARDANO_NODE_SOCKET_PATH=$(CURDIR)/node.socket                        ; \
	cardano-cli query protocol-parameters --testnet-magic $(CARDANO_TESTNET_MAGIC) \
	                                      --out-file $@
