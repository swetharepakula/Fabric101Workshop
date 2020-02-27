#!/bin/bash

export FABRIC_CFG_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

function one_line_pem {
    echo "`awk 'NF {sub(/\\n/, ""); printf "%s\\\\\\\n",$0;}' $1`"
}

function json_ccp {
    local PP=$(one_line_pem $4)
    local CP=$(one_line_pem $5)
    sed -e "s/\${ORG}/$1/" \
        -e "s/\${P0PORT}/$2/" \
        -e "s/\${CAPORT}/$3/" \
        -e "s#\${PEERPEM}#$PP#" \
        -e "s#\${CAPEM}#$CP#" \
        ${FABRIC_CFG_PATH}/ccp-template.json
}

echo "Generating Connection Profile for Org1"

ORG=1
P0PORT=7051
P1PORT=8051
CAPORT=7054
PEERPEM=${FABRIC_CFG_PATH}/crypto-config/peerOrganizations/org1.example.com/tlsca/tlsca.org1.example.com-cert.pem
CAPEM=${FABRIC_CFG_PATH}/crypto-config/peerOrganizations/org1.example.com/ca/ca.org1.example.com-cert.pem

echo "$(json_ccp $ORG $P0PORT $CAPORT $PEERPEM $CAPEM)" > ${FABRIC_CFG_PATH}/fabcar/connection-org1.json

echo "Generating Connection Profile for Org2"
ORG=2
P0PORT=9051
P1PORT=10051
CAPORT=9054
PEERPEM=${FABRIC_CFG_PATH}/crypto-config/peerOrganizations/org2.example.com/tlsca/tlsca.org2.example.com-cert.pem
CAPEM=${FABRIC_CFG_PATH}/crypto-config/peerOrganizations/org2.example.com/ca/ca.org2.example.com-cert.pem

echo "$(json_ccp $ORG $P0PORT $CAPORT $PEERPEM $CAPEM)" > ${FABRIC_CFG_PATH}/fabcar/connection-org2.json
