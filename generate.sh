#!/bin/sh
#
# Copyright IBM Corp All Rights Reserved
#
# SPDX-License-Identifier: Apache-2.0
#

export FABRIC_CFG_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
export PATH="${FABRIC_CFG_PATH}/bin:${PATH}"
CHANNEL_NAME=mychannel

# remove previous crypto material and config transactions
rm -fr ${FABRIC_CFG_PATH}/config/*
rm -fr ${FABRIC_CFG_PATH}/crypto-config/*

# generate crypto material
cryptogen generate --config=${FABRIC_CFG_PATH}/crypto-config.yaml --output "${FABRIC_CFG_PATH}/crypto-config"
if [ "$?" -ne 0 ]; then
  echo "Failed to generate crypto material..."
  exit 1
fi

# move private key to more convenient and consistent name
mv ${FABRIC_CFG_PATH}/crypto-config/peerOrganizations/org1.example.com/ca/*_sk ${FABRIC_CFG_PATH}/crypto-config/peerOrganizations/org1.example.com/ca/ca.org1.example.com_sk
mv ${FABRIC_CFG_PATH}/crypto-config/peerOrganizations/org2.example.com/ca/*_sk ${FABRIC_CFG_PATH}/crypto-config/peerOrganizations/org2.example.com/ca/ca.org2.example.com_sk

# generate genesis block for orderer
configtxgen -profile OrdererEtcdRaftGenesis -channelID ordererchannel -outputBlock ${FABRIC_CFG_PATH}/config/genesis.block
if [ "$?" -ne 0 ]; then
  echo "Failed to generate orderer genesis block..."
  exit 1
fi

# generate channel configuration transaction
configtxgen -profile TwoOrgsChannel -outputCreateChannelTx ${FABRIC_CFG_PATH}/config/channel.tx -channelID $CHANNEL_NAME
if [ "$?" -ne 0 ]; then
  echo "Failed to generate channel configuration transaction..."
  exit 1
fi

# generate anchor peer transaction
configtxgen -profile TwoOrgsChannel -outputAnchorPeersUpdate ${FABRIC_CFG_PATH}/config/Org1MSPanchors.tx -channelID $CHANNEL_NAME -asOrg Org1MSP
if [ "$?" -ne 0 ]; then
  echo "Failed to generate anchor peer update for Org1MSP..."
  exit 1
fi

# generate anchor peer transaction
configtxgen -profile TwoOrgsChannel -outputAnchorPeersUpdate ${FABRIC_CFG_PATH}/config/Org2MSPanchors.tx -channelID $CHANNEL_NAME -asOrg Org2MSP
if [ "$?" -ne 0 ]; then
  echo "Failed to generate anchor peer update for Org2MSP..."
  exit 1
fi

${FABRIC_CFG_PATH}/ccp-generate.sh
