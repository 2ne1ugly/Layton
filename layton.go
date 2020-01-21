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
	Username     string `db:"username"`
	sessionToken string
}

//LaytonServer is where data is stored in to run the server
type LaytonServer struct {
	bInitialized   bool
	onlineAccounts map[string]Account //Key is username
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
	_, ok := layton.onlineAccounts[account.Username]
	if ok {
		return false
	}
	account.sessionToken = account.Username + "_" + strconv.FormatInt(int64(len(layton.onlineAccounts)), 10)

	//Add to onlineAccounts
	layton.onlineAccounts[account.Username] = *account
	return true
}

//LogOutFromLayton returns false for failure, true for success
func LogOutFromLayton(account Account) bool {
	if !layton.bInitialized {
		log.Fatal("Layton Not Initialized")
	}

	//Check if account is logged in
	_, ok := layton.onlineAccounts[account.Username]
	if !ok {
		return false
	}

	//delete from onlineAccounts
	delete(layton.onlineAccounts, account.Username)
	return true
}
