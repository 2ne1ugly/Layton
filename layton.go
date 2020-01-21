//
// Contains all necessary server information
//
package main

import (
	"log"
	"strconv"
)

//Account represents "RAM" version of account info.
type Account struct {
	userID       string
	sessionToken string
}

//LaytonServer is where data is stored in to run the server
type LaytonServer struct {
	bInitialized   bool
	onlineAccounts map[string]Account //Key is userID
}

var layton LaytonServer

//InitLayton initializes global variable layton
func InitLayton() {
	layton.bInitialized = true
}

//LogIntoLayton returns false for failure, true for success. Also modifies it so that it contains session token.
func LogIntoLayton(account *Account) bool {
	if !layton.bInitialized {
		log.Fatal("Layton Not Initialized")
	}

	//Check if account is logged in
	_, ok := layton.onlineAccounts[account.userID]
	if ok {
		return false
	}
	account.sessionToken = account.userID + "_" + strconv.FormatInt(int64(len(layton.onlineAccounts)), 10)

	//Add to onlineAccounts
	layton.onlineAccounts[account.userID] = *account
	return true
}

//LogOutFromLayton returns false for failure, true for success
func LogOutFromLayton(account Account) bool {
	if !layton.bInitialized {
		log.Fatal("Layton Not Initialized")
	}

	//Check if account is logged in
	_, ok := layton.onlineAccounts[account.userID]
	if !ok {
		return false
	}

	//delete from onlineAccounts
	delete(layton.onlineAccounts, account.userID)
	return true
}
