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
