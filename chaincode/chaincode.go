/*
 * Copyright IBM Corp All Rights Reserved
 *
 * SPDX-License-Identifier: Apache-2.0
 *
 */

package main

/* Imports
 * 4 utility libraries for formatting, handling bytes, reading and writing JSON, and string manipulation
 * 2 specific Hyperledger Fabric specific libraries for Smart Contracts
 */
import (
	"encoding/json"
	"fmt"

	"github.com/hyperledger/fabric/core/chaincode/shim"
	sc "github.com/hyperledger/fabric/protos/peer"
)

const allKeysKey = "keys"

//SmartContract is the data structure which represents this contract and on which  various contract lifecycle functions are attached
type SmartContract struct {
}

type data struct {
	Name     string
	Node     string
	Org      string
	Question string
}

type storedKeys map[string]bool

// Define Status codes for the response
const (
	OK    = 200
	ERROR = 500
)

// Init is called when the smart contract is instantiated
func (s *SmartContract) Init(APIstub shim.ChaincodeStubInterface) sc.Response {
	fmt.Println("Init cc, it's no-op")
	return shim.Success(nil)
}

// Invoke routes invocations to the appropriate function in chaincode
// Current supported invocations are:
//	- get, retrieves the value of a variable in the ledger
//      - put, put something in the ledger
//	- delete, the variable
func (s *SmartContract) Invoke(APIstub shim.ChaincodeStubInterface) sc.Response {
	// Retrieve the requested Smart Contract function and arguments
	function, args := APIstub.GetFunctionAndParameters()
	fmt.Printf("Invoke cc, function:%s function, args: %+v", function, args)

	// Route to the appropriate handler function to interact with the ledger appropriately
	switch function {
	case "get":
		return s.get(APIstub, args)
	case "getKeys":
		return s.getKeys(APIstub)
	case "put":
		return s.put(APIstub, args)
	default:
		return shim.Error("Invalid Smart Contract function name.")
	}
}

// The main function is only relevant in unit test mode. Only included here for completeness.
func main() {
	// Create a new Smart Contract
	err := shim.Start(new(SmartContract))
	if err != nil {
		fmt.Printf("Error creating new Smart Contract: %s", err)
	}
}

/**
 * All functions below this are for testing traditional editing of a single row
 */
func (s *SmartContract) put(APIstub shim.ChaincodeStubInterface, args []string) sc.Response {

	if len(args) < 4 {
		return shim.Error("not enough args")
	}
	var input data

	input.Name = args[0]
	input.Node = args[1]
	input.Org = args[2]
	input.Question = args[3]

	key := input.Name + input.Node + input.Org

	keys, getErr := APIstub.GetState(allKeysKey)
	if getErr != nil {
		return shim.Error(fmt.Sprintf("Failed to retrieve the state of %s: %s", allKeysKey, getErr.Error()))
	}
	// no record of any keys, start a record
	if keys == nil {
		keys, _ = json.Marshal(storedKeys{})
	}
	var allKeys storedKeys
	err := json.Unmarshal(keys, &allKeys)
	if err != nil {
		return shim.Error(fmt.Sprintf("Failed to unmarshal stored keys: %s", err))
	}
	// key not present, add it
	if _, present := allKeys[key]; !present {
		allKeys[key] = true
	}
	bytes, err := json.Marshal(allKeys)
	if err != nil {
		return shim.Error(fmt.Sprintf("Failed to marshal stored keys: %s", err))
	}
	putErr := APIstub.PutState(allKeysKey, bytes)
	if putErr != nil {
		return shim.Error(fmt.Sprintf("Failed to put state: %s", putErr.Error()))
	}

	bytes, err = json.Marshal(input)
	if err != nil {
		return shim.Error(fmt.Sprintf("Failed to marshal: %s", err))
	}
	putErr = APIstub.PutState(key, bytes)
	if putErr != nil {
		return shim.Error(fmt.Sprintf("Failed to put state: %s", putErr.Error()))
	}

	return shim.Success(nil)
}

func (s *SmartContract) get(APIstub shim.ChaincodeStubInterface, args []string) sc.Response {
	if len(args) < 3 {
		return shim.Error("not enough args")
	}
	var input data

	input.Name = args[0]
	input.Node = args[1]
	input.Org = args[2]

	key := input.Name + input.Node + input.Org

	val, getErr := APIstub.GetState(key)
	if getErr != nil {
		return shim.Error(fmt.Sprintf("Failed to get state: %s", getErr.Error()))
	}
	if val == nil {
		return shim.Error("key does not exist")
	}

	var output data

	err := json.Unmarshal(val, &output)
	if err != nil {
		return shim.Error(fmt.Sprintf("Failed to unmarshal: %s", err))
	}

	return shim.Success(val)
}

func (s *SmartContract) getKeys(APIstub shim.ChaincodeStubInterface) sc.Response {

	val, getErr := APIstub.GetState(allKeysKey)
	if getErr != nil {
		return shim.Error(fmt.Sprintf("Failed to get state: %s", getErr.Error()))
	}
	if val == nil {
		return shim.Error("key does not exist")
	}

	var output storedKeys

	err := json.Unmarshal(val, &output)
	if err != nil {
		return shim.Error(fmt.Sprintf("Failed to unmarshal: %s", err))
	}

	return shim.Success(val)
}
