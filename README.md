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
./scripts/bootstrap.sh -s
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
Ensure you have 5 containers running. A peer, an orderer, a ca, couchdb, and cli.

## Install the Chaincode

1. Exec into the cli container. The cli container is configured with all the tools
and certificates needed to talk to the peer and orderer node.
```
docker exec -it cli bash
```

2. Package the chaincode. The chaincode has already been mounted into the
peer container. You can see more details in [`docker-compose.yml`](./docker-compose.yml).
```
peer lifecycle chaincode package fabcar.tar.gz --path /opt/gopath/src/github.com/chaincode/ --lang node --label fabcar1
```

3. Install the chaincode using the package.
```
peer lifecycle chaincode install fabcar.tar.gz
```
You should see a nodeenv container run to completion.

4. Query the peer for the installed chain code to get the Package ID.
```
$ peer lifecycle chaincode queryinstalled
Installed chaincodes on peer:
Package ID: fabcar1:cb90821c789b3584ed7c388269a85e51997ac3042908ba380aabbc265f52af05, Label: fabcar1
```

5. Approve the chaincode for running.
```
peer lifecycle chaincode approveformyorg --channelID mychannel --name fabcar --version 1 --sequence 1 --package-id fabcar1:433b167e5a9d9b3dd089ca4e4a9f757f0f2effbc1255e9a7b3a2313860a797ff
```

6. Check the whether it's approved by all organizations.
```
$ peer lifecycle chaincode checkcommitreadiness -C mychannel -n fabcar -v 1
Chaincode definition for chaincode 'fabcar', version '1', sequence '1' on channel 'mychannel' approval status by org:
Org1MSP: true
```

7. Commit the chaincode.
```
$ peer lifecycle chaincode commit -C mychannel -n fabcar -v 1 --sequence 1
2020-02-07 00:12:45.478 UTC [cli.lifecycle.chaincode] setOrdererClient -> INFO 001 Retrieved channel (mychannel) orderer endpoint: orderer.example.com:7050
2020-02-07 00:12:47.623 UTC [chaincodeCmd] ClientWait -> INFO 002 txid [7eea31d96ebf6949130045a83cd948bc7dd43226f0ece18c6dc787e02d97eeba] committed with status (VALID) at
```
You should see a fabcar container running.

8. Ensure chaincode has been committed.
```
$ peer lifecycle chaincode querycommitted -C mychannel
Committed chaincode definitions on channel 'mychannel':
Name: fabcar, Version: 1, Sequence: 1, Endorsement Plugin: escc, Validation Plugin: vscc
```

## Interact with the Deployed Chaincode

### Using the Peer CLI
Lets us the peer cli to initialize the chaincode

1. Initialize the ledger.
```
peer chaincode invoke -n fabcar -C mychannel -c '{"function":"initLedger","Args":[]}'
```

2. Query for the data populated in the ledger.
```
peer chaincode query -n fabcar -C mychannel -c '{"function":"queryAllCars","Args":[]}'
```

3. Exit out of the container
```
Ctrl+D
```

### Using the Node SDK

#### Setting up the credentials

1. Navigate to the fabcar directory
```
cd fabcar
```

2. Enroll as the Admin user. You should now see files under the directory `wallet/admin`
```
node enrollAdmin.js
```

3. Register a new user using the admin credential. You should files for user1 in `wallet/user1`
```
node registerUser.js
```

#### Interact with the deployed Chaincode

1. Query All the Cars
```
node query.js
```

2. Edit `query.js` (line 44) to query for a particular key.
```
const result = await contract.evaluateTransaction('queryCar', 'CAR4');
```

3. Run the query script again. You should see only one result back.
```
node query.js
```

4. Add a car to the ledger by invoking the chaincode.
```
node invoke.js
```

5. Edit `query.js` (line 44) to query for the car associated with 'CAR10'
```
const result = await contract.evaluateTransaction('queryCar', 'CAR10');
```

6. Verify that the ledger has been updated by querying for `CAR10`
```
node query.js
```

7. Edit `invoke.js` (line 44) to be able to change the car owner of `CAR8` to yourself.
```
await contract.submitTransaction('changeCarOwner', 'CAR8', '<your-name>');
```

8. Run the `invoke.js` to change the owner of `CAR8` to yourself
```
node invoke.js
```

9. Edit `query.js` and run it to verify that the owner of `CAR8` is now yourself

## Teardown the network

1. Run the [teardown script](./teardown.sh) to clean up your environment. Run this in the root of this repo. **NOTE** This will try to
remove all your containers and prune all excess volumes.
```
./teardown.sh
```
