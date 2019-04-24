# Hyperledger Fabric 101 Workshop


### Prerequisites

- [Docker](https://www.docker.com/get-started) version 17.06.2-ce or greater is required.
- [Go](https://golang.org/dl/) 1.10 or Go 1.11
- [Node](https://nodejs.org/en/download/releases/) 8.9.0 or 9.0
- Download [Fabric v1.4 Binaries and Docker Images](https://hyperledger-fabric.readthedocs.io/en/release-1.4/install.html)
by running [scripts/bootstrap.sh](scripts/bootstrap.sh). The script will download
all the Fabric binaries and docker images needed for this workshop.
```
./scripts/bootstrap.sh
```
**NOTE** For Windows users, follow the directions on the [Fabric Documentation](https://hyperledger-fabric.readthedocs.io/en/release-1.4/install.html)
to download the binaries and images associated with Fabric v1.4.1.

**NOTE** Windows users are welcome to try the workshop, however it is aimed
towards those using unix environments and may not always work in Windows environments.

## Start up the Network
1. To generate certs we are going to use some of the development binaries that
you downloaded as part of the prerequisites.
```
./generate.sh
```
You should see two folders, `crypto-config` and `config`.

2. Start up the network. The script will create docker containers that will run a
peer and an orderer. They are configured by the [`docker-compose.yml`](./docker-compose.yml). This script will also be creating a channel and joining the peer
to that channel. For more details take a look at [`start.sh`](./start.sh)
```
./start.sh
```

## Install the Chaincode

1. Exec into the cli container. The cli container is configured with all the tools
and certificates needed to talk to the peer and orderer node.
```
docker exec -it cli bash
```

2. Next install the chaincode. The chaincode has already been mounted into the
peer container. You can see more details in [`docker-compose.yml`](./docker-compose.yml).
```
peer chaincode install -n mycc -v 1.0 -p github.com/chaincode
```

3. Instantiate the chaincode. This will run the `Init` command. At the end of this
you should see a new container appear which is the chaincode container.
```
peer chaincode instantiate -n mycc -v 1.0 -C mychannel -c '{"Args":[]}'
```

## Interact with the Deployed Chaincode

1. Add an entry to the ledger.
```
peer chaincode invoke -n mycc -C mychannel -c '{"Args":["put","myname","mypeer","myorg","myanswer"]}'
```

2. Get all the keys from the ledger
```
peer chaincode query -n mycc -C mychannel -c '{"Args":["getKeys"]}'
```

3. Query a particular key
```
peer chaincode query -n mycc -C mychannel -c '{"Args":["get","myname","mypeer","myorg"]}'
```

4. Update the value of a key
```
peer chaincode invoke -n mycc -C mychannel -c '{"Args":["put","myname","mypeer","myorg2","mydifferentanswer"]}'
```

## Teardown the network

1. Run the [teardown script](./teardown.sh) to clean up your environment **NOTE** This will try to
remove all your containers and prune all excess volumes.
```
./teardown.sh
```
