This repo takes many files from the basic network and first network examples
in Fabric Samples. The scripts and configurations are modified versions of
those two examples. This includes the scripts, the configuration files, the
chaincodes and the connection profile template. Modifications have been done
to make the base network with 2 orgs, 1 peer each, and a single orderer using
raft. The chaincodes have been altered so they are compatible with each other.

The bootstrap script is slightly modified from the Fabric repo so that the
binaries are downloaded relative to the script location and not from where the
script was run from.

Sources:
https://github.com/hyperledger/fabric-samples/tree/master/basic-network
https://github.com/hyperledger/fabric-samples/tree/master/first-network
https://github.com/hyperledger/fabric/blob/master/scripts/bootstrap.sh
