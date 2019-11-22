#!/bin/bash
set -u
set -e

echo "[*] Starting Hyperledger Besu nodes"

GENESIS=~/besu-node/data/genesis.json
NODE_CONF=~/besu-node/data/configs
LOGS=~/besu-chain/logs

NODE_DATA=~/besu-chain/data/Node-1/data
besu --data-path="$NODE_DATA" --genesis-file="$GENESIS" --config-file="$NODE_CONF"/node1.toml >> "$LOGS"/1.log &
sleep 5

NODE_DATA=~/besu-chain/data/Node-2/data
besu --data-path="$NODE_DATA" --genesis-file="$GENESIS" --config-file="$NODE_CONF"/node2.toml >> "$LOGS"/2.log &
sleep 5

NODE_DATA=~/besu-chain/data/Node-3/data
besu --data-path="$NODE_DATA" --genesis-file="$GENESIS" --config-file="$NODE_CONF"/node3.toml >> "$LOGS"/3.log &
sleep 5

NODE_DATA=~/besu-chain/data/Node-4/data
besu --data-path="$NODE_DATA" --genesis-file="$GENESIS" --config-file="$NODE_CONF"/node4.toml >> "$LOGS"/4.log &
sleep 5

echo "[*] Waiting for nodes to start"
sleep 15

echo "All nodes started. See '~/besu-chain/logs' for logs, and run e.g. 'geth attach http://127.0.0.1:22000' to attach to the first Geth node."
