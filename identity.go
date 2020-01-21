package main

import (
	"encoding/json"
	"net/http"

	"github.com/gorilla/mux"
)

//
// createAccount
//
type createAccountRequest struct {
	UserId string `json:"userId"`
}

type createAccountResponse struct {
	ResultCode int64 `json:"ResultCode"`
}

func createAccountHandler(w http.ResponseWriter, r *http.Request) {
	LaytonLog("Handling create account")

	//Read json
	var request createAccountRequest
	if !ReadJSON(r, request) {
		LaytonLog("Create Account Bad request")
		w.WriteHeader(http.StatusBadRequest)
		return
	}
	LaytonLog(request.UserId)

	//Setup Response and defer sending response
	w.Header().Set("Content-Type", "application/json")
	var response createAccountResponse
	defer func() {
		responseBlob, err := json.Marshal(response)
		if err != nil {
			LaytonLog("Create Account Failed to marshal")
			w.WriteHeader(http.StatusInternalServerError)
			return
		}
		w.Write(responseBlob)
	}()

	//Query if it already exists
	var queryUserId string
	row := DB.QueryRow("SELECT userId FROM accounts WHERE userId = ?", request.UserId)
	err := row.Scan(queryUserId)
	if err == nil {
		response.ResultCode = AlreadyExists
		return
	}

	//Try to insert it
	_, err1 := DB.Exec("INSERT INTO accounts (userId) VALUES (?)", request.UserId)
	if err1 != nil {
		LaytonLog("Create Account Internal Error")
		response.ResultCode = InternalError
		return
	}

	//send response
	response.ResultCode = Ok
}

//
// login
//
type loginRequest struct {
	UserId string `json:"userId"`
}

type loginResponse struct {
	ResultCode  int64  `json:"ResultCode"`
	AccessToken string `json:"AccessToken"`
}

func loginHandler(w http.ResponseWriter, r *http.Request) {
	LaytonLog("Handling Login")
	//Read json
	var request loginRequest
	if !ReadJSON(r, request) {
		LaytonLog("Create Account Bad request")
		w.WriteHeader(http.StatusBadRequest)
		return
	}

	//Setup Response and defer sending response
	w.Header().Set("Content-Type", "application/json")
	var response loginResponse
	defer func() {
		responseBlob, err := json.Marshal(response)
		if err != nil {
			LaytonLog("login Failed to marshal")
			w.WriteHeader(http.StatusInternalServerError)
			return
		}
		w.Write(responseBlob)
	}()

	//Query if it already exists
	var queriedAccount Account
	row := DB.QueryRow("SELECT userId FROM accounts WHERE userId = ?", request.UserId)
	err := row.Scan(queriedAccount)
	if err != nil {
		response.ResultCode = IncorrectCredentials
		return
	}

	//Log into layton
	if LogIntoLayton(&queriedAccount) {
		response.ResultCode = Ok
		response.AccessToken = queriedAccount.sessionToken
	} else {
		response.ResultCode = InternalError
	}
}

//
// logout
//
type logoutRequest struct {
	UserId string `json:"userId"`
}

type logoutResponse struct {
	ResultCode int64 `json:"resultCode"`
}

func logoutHandler(w http.ResponseWriter, r *http.Request) {
	LaytonLog("Handling Logout")

	//Read json
	var request logoutRequest
	if !ReadJSON(r, request) {
		LaytonLog("Create Account Bad request")
		w.WriteHeader(http.StatusBadRequest)
		return
	}

	//Setup Response and defer sending response
	w.Header().Set("Content-Type", "application/json")
	var response logoutResponse
	defer func() {
		responseBlob, err := json.Marshal(response)
		if err != nil {
			LaytonLog("logout Failed to marshal")
			w.WriteHeader(http.StatusInternalServerError)
			return
		}
		w.Write(responseBlob)
	}()

	//Query if it already exists
	var queriedAccount Account
	row := DB.QueryRow("SELECT userId FROM accounts WHERE userId = ?", request.UserId)
	err := row.Scan(queriedAccount)
	if err != nil {
		LaytonLog("Logout Account does not exist")
		response.ResultCode = DoesNotExist
		return
	}

	//Log out layton
	if LogOutFromLayton(queriedAccount) {
		response.ResultCode = Ok
	} else {
		response.ResultCode = AlreadyLoggedOut
	}
}

//BindIdentityHandlers Binds Identity related handles
func BindIdentityHandlers(r *mux.Router) {
	r.HandleFunc("/Identity/CreateAccount", createAccountHandler)
	r.HandleFunc("/Identity/Login", loginHandler)
	r.HandleFunc("/Identity/Logout", logoutHandler)
}
