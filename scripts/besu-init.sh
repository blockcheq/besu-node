#!/bin/bash
set -u
set -e

echo "[*] Cleaning up temporary data directories"
rm -rf ~/besu-chain/data
rm -rf ~/besu-chain/logs
mkdir -p ~/besu-chain/logs

NODE_NAME="Node-1"
echo "[*] Configuring node $NODE_NAME"
mkdir -p ~/besu-chain/data/"$NODE_NAME"/data/
cp ~/besu-node/data/keys/tm1 ~/besu-chain/data/"$NODE_NAME"/data/key
cp ~/besu-node/data/keys/tm1.pub ~/besu-chain/data/"$NODE_NAME"/data/key.pub

NODE_NAME="Node-2"
echo "[*] Configuring node $NODE_NAME"
mkdir -p ~/besu-chain/data/"$NODE_NAME"/data/
cp ~/besu-node/data/keys/tm2 ~/besu-chain/data/"$NODE_NAME"/data/key
cp ~/besu-node/data/keys/tm2.pub ~/besu-chain/data/"$NODE_NAME"/data/key.pub

NODE_NAME="Node-3"
echo "[*] Configuring node $NODE_NAME"
mkdir -p ~/besu-chain/data/"$NODE_NAME"/data/
cp ~/besu-node/data/keys/tm3 ~/besu-chain/data/"$NODE_NAME"/data/key
cp ~/besu-node/data/keys/tm3.pub ~/besu-chain/data/"$NODE_NAME"/data/key.pub

NODE_NAME="Node-4"
echo "[*] Configuring node $NODE_NAME"
mkdir -p ~/besu-chain/data/"$NODE_NAME"/data/
cp ~/besu-node/data/keys/tm4 ~/besu-chain/data/"$NODE_NAME"/data/key
cp ~/besu-node/data/keys/tm4.pub ~/besu-chain/data/"$NODE_NAME"/data/key.pub

echo "[*] Initialization was completed successfully."

set +u
set +e
