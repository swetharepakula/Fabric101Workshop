#!/bin/bash
#
# Copyright IBM Corp All Rights Reserved
#
# SPDX-License-Identifier: Apache-2.0
#
# Exit on first error, print all commands.
set -ev

export FABRIC_CFG_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# don't rewrite paths for Windows Git Bash users
export MSYS_NO_PATHCONV=1
export COMPOSE_PROJECT_NAME=fabric101

docker-compose -f ${FABRIC_CFG_PATH}/docker-compose.yml down

docker-compose -f ${FABRIC_CFG_PATH}/docker-compose.yml up -d
docker ps -a

# wait for Hyperledger Fabric to start
# incase of errors when running later commands, issue export FABRIC_START_TIMEOUT=<larger number>
export FABRIC_START_TIMEOUT=10
#echo ${FABRIC_START_TIMEOUT}
sleep ${FABRIC_START_TIMEOUT}

# Create the channel
docker exec -e "CORE_PEER_LOCALMSPID=Org1MSP" -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@org1.example.com/msp" peer0.org1.example.com peer channel create -o orderer.example.com:7050 --tls --cafile /etc/hyperledger/fabric/orderer/orderer-ca.crt -c mychannel -f /etc/hyperledger/configtx/channel.tx --outputBlock /etc/hyperledger/configtx/mychannel.block

# Join peer0.org1.example.com to the channel.
docker exec -e "CORE_PEER_LOCALMSPID=Org1MSP" -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@org1.example.com/msp" peer0.org1.example.com peer channel join --tls --cafile /etc/hyperledger/fabric/orderer/orderer-ca.crt -b /etc/hyperledger/configtx/mychannel.block

# Join peer0.org2.example.com to the channel.
docker exec -e "CORE_PEER_LOCALMSPID=Org2MSP" -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@org2.example.com/msp" peer0.org2.example.com peer channel join --tls --cafile /etc/hyperledger/fabric/orderer/orderer-ca.crt -b /etc/hyperledger/configtx/mychannel.block

docker exec -e "CORE_PEER_LOCALMSPID=Org1MSP" -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@org1.example.com/msp" peer0.org1.example.com peer channel update -o orderer.example.com:7050 -c mychannel -f /etc/hyperledger/configtx/Org1MSPanchors.tx --tls --cafile /etc/hyperledger/fabric/orderer/orderer-ca.crt

docker exec -e "CORE_PEER_LOCALMSPID=Org2MSP" -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@org2.example.com/msp" peer0.org2.example.com peer channel update -o orderer.example.com:7050 -c mychannel -f /etc/hyperledger/configtx/Org2MSPanchors.tx --tls --cafile /etc/hyperledger/fabric/orderer/orderer-ca.crt
