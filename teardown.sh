#!/bin/bash
#
# Copyright IBM Corp All Rights Reserved
#
# SPDX-License-Identifier: Apache-2.0
#
# Exit on first error, print all commands.
set -e

export COMPOSE_PROJECT_NAME=fabric101
export FABRIC_CFG_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# Shut down the Docker containers for the system tests.
docker-compose -f ${FABRIC_CFG_PATH}/docker-compose.yml kill && docker-compose -f ${FABRIC_CFG_PATH}/docker-compose.yml down

# remove the local state
rm -f ~/.hfc-key-store/*

# remove chaincode docker images
docker rm $(docker ps -aq)
docker rmi $(docker images dev-* -q)
docker rm fabcar-nodejs
docker rmi fabcar-nodejs

# Your system is now clean
