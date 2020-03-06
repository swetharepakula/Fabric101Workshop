# Hyperledger Fabric 101 Workshop


## Prerequisites

- [Docker](https://www.docker.com/get-started) version 17.06.2-ce or greater is required.
- [Node](https://nodejs.org/en/download/releases/) versions 8-10
- Git clone this repo
```
git clone https://github.com/swetharepakula/Fabric101Workshop
```
- Download [Fabric v2.0 Binaries and Docker Images](https://hyperledger-fabric.readthedocs.io/en/release-2.0/install.html)
by running [scripts/bootstrap.sh](scripts/bootstrap.sh). The script will download
all the Fabric binaries and docker images needed for this workshop.
```
./bootstrap.sh -s
```
- Download the Node modules needed.
```
cd fabcar
npm install
```

**NOTE** For Windows users, follow the directions on the [Fabric Documentation](https://hyperledger-fabric.readthedocs.io/en/release-2.0/install.html)
to download the binaries and images associated with Fabric v2.0.0.

**NOTE** Windows users are welcome to try the workshop, however it is aimed
towards those using unix environments and may not always work in Windows environments.

---

# Workshop

## Start up the Network
1. To generate certs we are going to use some of the development binaries that
you downloaded as part of the prerequisites. This script will also create
connection profiles that are necessary to use SDKs later in this workshop.
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
Ensure you have 6 containers running. Two peers, an orderer, a ca, and two cli.

## Install the Chaincode

1. Exec into the Org1 cli container. The cli container is configured with all the tools
and certificates needed to talk to the peers and orderer node.
```
docker exec -it org1-cli bash
```

2. Package the node chaincode. The chaincode has already been mounted into the
peer container. You can see more details in [`docker-compose.yml`](./docker-compose.yml).
```
peer lifecycle chaincode package fabcar-js.tar.gz --path /opt/gopath/src/github.com/chaincode/javascript --lang node --label fabcar1
```

3. Install the chaincode using the package.
```
peer lifecycle chaincode install fabcar-js.tar.gz
```
You should see a nodeenv container run to completion.

4. Query the peer for the installed chain code to get the Package ID.
```
$ peer lifecycle chaincode queryinstalled
Installed chaincodes on peer:
Package ID: fabcar1:<uuid>, Label: fabcar1
```

5. In another terminal, exec into the Org2 cli container. The cli container is
configured with all the tools and certificates needed to talk to the peers and
orderer node.
```
docker exec -it org2-cli bash
```

6. Package the go chaincode. The chaincode has already been mounted into the
peer container. You can see more details in [`docker-compose.yml`](./docker-compose.yml).
```
peer lifecycle chaincode package fabcar-go.tar.gz --path /opt/gopath/src/github.com/chaincode/go --lang golang --label fabcar1
```

7. Install the chaincode using the package.
```
peer lifecycle chaincode install fabcar-go.tar.gz
```
You should see a ccenv container run to completion.

8. Query the peer for the installed chain code to get the Package ID.
```
$ peer lifecycle chaincode queryinstalled
Installed chaincodes on peer:
Package ID: fabcar1:<uuid>, Label: fabcar1
```
The package id is different from the node version of the chaincode
package, but the label is the same.

9. Approve the chaincode for running. Remember to update the package-id to
corresponding id from your installation.
```
peer lifecycle chaincode approveformyorg --channelID mychannel --name fabcar --version 1 --sequence 1 --tls --cafile $ORDERER_CA --package-id <org2-installation-package-id>
```

10. Check the whether it's approved by Org2.
```
$ peer lifecycle chaincode checkcommitreadiness -C mychannel -n fabcar -v 1
Chaincode definition for chaincode 'fabcar', version '1', sequence '1' on channel 'mychannel' approval status by org:
Org1MSP: false
Org2MSP: true
```

11. Switch back to the terminal with the Org1 CLI container, and approve the
chaincode for running.
```
peer lifecycle chaincode approveformyorg --channelID mychannel --name fabcar --version 1 --sequence 1 --tls --cafile $ORDERER_CA --package-id <org1-installation-package-id>
```

12. Check that the chaincode definition has been approved by all organizations.
```
$ peer lifecycle chaincode checkcommitreadiness -C mychannel -n fabcar -v 1
Chaincode definition for chaincode 'fabcar', version '1', sequence '1' on channel 'mychannel' approval status by org:
Org1MSP: true
Org2MSP: true
```

13. Commit the chaincode.
```
$ peer lifecycle chaincode commit -C mychannel -n fabcar -v 1 --sequence 1 --tls -o orderer.example.com:7050 --cafile $ORDERER_CA --peerAddresses peer0.org1.example.com:7051 --peerAddresses peer0.org2.example.com:9051 --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt
2020-02-21 20:30:44.846 UTC [cli.lifecycle.chaincode] setOrdererClient -> INFO 001 Retrieved channel (mychannel) orderer endpoint: orderer.example.com:7050
2020-02-21 20:30:47.041 UTC [chaincodeCmd] ClientWait -> INFO 002 txid [c8363b39fd60ce32992d131752480761fd1b8aa107ad8095c9db0f25394ac8cd] committed with status (VALID) at peer0.org1.example.com:7051
2020-02-21 20:30:47.099 UTC [chaincodeCmd] ClientWait -> INFO 003 txid [c8363b39fd60ce32992d131752480761fd1b8aa107ad8095c9db0f25394ac8cd] committed with status (VALID) at peer0.org2.example.com:9051
```
You should see two fabcar container running.

14. Ensure chaincode has been committed.
```
$ peer lifecycle chaincode querycommitted -C mychannel
Committed chaincode definitions on channel 'mychannel':
Name: fabcar, Version: 1, Sequence: 1, Endorsement Plugin: escc, Validation Plugin: vscc
```

## Interact with the Deployed Chaincode

### Using the Peer CLI
Lets use the peer cli to initialize the chaincode

1. Initialize the ledger in either org's cli container.
```
peer chaincode invoke -n fabcar -C mychannel -c '{"function":"InitLedger","Args":[]}' -o orderer.example.com:7050 --tls --cafile $ORDERER_CA --peerAddresses peer0.org1.example.com:7051 --peerAddresses peer0.org2.example.com:9051 --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt
```

2. Query for the data populated in the ledger.
```
peer chaincode query -n fabcar -C mychannel -c '{"function":"QueryAllCars","Args":[]}'
```

3. Exit out of the containers.
```
Ctrl+D
```

### Using the Node SDK

#### Setting up the credentials

1. Navigate to the fabcar directory
```
cd fabcar
```

2. Enroll as the Admin user. You should now see files under the directory `wallet/org1/admin`
```
node enrollAdmin.js org1
```

3. Register a new user using the admin credential. You should see new files created for your
chosen username in `wallet/org1/<username>`.
```
node registerUser.js org1 <username>
```

#### Interact with the deployed Chaincode

1. Query All the Cars
```
node query.js org1 <username> QueryAllCars
```

2. Query for a particular key. You should see only one result back.
```
node query.js org1 <username> QueryCar CAR4
```

3. Add a car to the ledger by invoking the chaincode.
```
node invoke.js org1 <username> CreateCar CAR12 Honda Accord Black Tom
```

4. Verify that the ledger has been updated by querying for `CAR12`
```
node query.js org1 <username> QueryCar CAR12
```

5. Submit a transaction to change the car owner of `CAR8` to yourself.
```
node invoke.js org1 <username> ChangeCarOwner CAR8 <your-name>
```

9. Run `query.js` to verify that the owner of `CAR8` is now yourself

## Teardown the network

1. Run the [teardown script](./teardown.sh) to clean up your environment. Run this in the root of this repo. **NOTE** This will try to
remove all your containers and prune all excess volumes.
```
./teardown.sh
```
