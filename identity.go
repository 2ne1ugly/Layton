package main

import (
	"database/sql"
	"encoding/json"
	"net/http"

	"github.com/gorilla/mux"
)

//
// createAccount
//
type createAccountRequest struct {
	Username string `json:"username"`
}

type createAccountResponse struct {
	ResultCode int64 `json:"resultCode"`
}

func createAccountHandler(w http.ResponseWriter, r *http.Request) {
	LaytonLog("Handling create account")

	//Read content
	data, ok := ReadContent(r)
	if !ok {
		LaytonLog("Create Account Bad request")
		return
	}
	LaytonLog(string(data))

	//Parse to Json
	var request createAccountRequest
	err2 := json.Unmarshal(data, &request)
	if err2 != nil {
		LaytonLog(err2.Error())
		return
	}

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
		LaytonLog(string(responseBlob))
		w.Write(responseBlob)
	}()

	//Query if it already exists
	queriedAccount := Account{}
	err := db.Get(&queriedAccount, "SELECT * FROM accounts WHERE username=$1", request.Username)
	if err != sql.ErrNoRows {
		if err != nil {
			LaytonLog(err.Error())
		}
		response.ResultCode = AlreadyExists
		return
	}

	//Try to insert it
	_, err = db.Queryx("INSERT INTO layton.accounts (username) VALUES ($1)", request.Username)
	if err != nil {
		LaytonLog(err.Error())
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
	Username string `json:"username"`
}

type loginResponse struct {
	ResultCode  int64  `json:"resultCode"`
	AccessToken string `json:"accessToken"`
}

func loginHandler(w http.ResponseWriter, r *http.Request) {
	LaytonLog("Handling Login")

	//Read content
	data, ok := ReadContent(r)
	if !ok {
		LaytonLog("Create Account Bad request")
		return
	}

	//Parse to JSON
	var request loginRequest
	err2 := json.Unmarshal(data, &request)
	if err2 != nil {
		LaytonLog(err2.Error())
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
	err := db.Get(&queriedAccount, "SELECT * FROM accounts WHERE username = ?", request.Username)
	if err != nil {
		LaytonLog(err.Error())
		LaytonLog("incorrect credentials")
		response.ResultCode = IncorrectCredentials
		return
	}

	//Log into layton
	if LogIntoLayton(&queriedAccount) {
		response.ResultCode = Ok
		response.AccessToken = queriedAccount.sessionToken
	} else {
		response.ResultCode = InternalError
		LaytonLog("internal error")
	}
}

//
// logout
//
type logoutRequest struct {
	Username string `json:"username"`
}

type logoutResponse struct {
	ResultCode int64 `json:"resultCode"`
}

func logoutHandler(w http.ResponseWriter, r *http.Request) {
	LaytonLog("Handling Logout")

	//Read content
	data, ok := ReadContent(r)
	if !ok {
		LaytonLog("Create Account Bad request")
		return
	}

	//Parse to JSON
	var request logoutRequest
	err2 := json.Unmarshal(data, &request)
	if err2 != nil {
		LaytonLog(err2.Error())
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
	err := db.Get(&queriedAccount, "SELECT username FROM accounts WHERE username = $1", request.Username)
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
