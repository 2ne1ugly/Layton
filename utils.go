package main

import (
	"encoding/json"
	"fmt"
	"io/ioutil"
	"net/http"
	"time"
)

//Result Codes
const (
	Ok = iota // starts at 0
	AlreadyExists
	InternalError
	AlreadyLoggedIn
	IncorrectCredentials
	AlreadyLoggedOut
	DoesNotExist
)

//LaytonLog logs to console output with timestamp
func LaytonLog(str string) {
	t := time.Now()
	fmt.Printf("%d-%02d-%02dT%02d:%02d:%02d-00:00: %s\n", t.Year(), t.Month(), t.Day(),
		t.Hour(), t.Minute(), t.Second(), str)
}

// ReadJSON reads json data blobs from header.
func ReadJSON(r *http.Request, jsonStruct interface{}) bool {
	//Check content type and if bad, return
	contentType := r.Header.Get("Content-Type")
	if contentType != "application/json" {
		return false
	}

	//Read Header
	data, err := ioutil.ReadAll(r.Body)
	if err != nil {
		LaytonLog(err.Error())
		return false
	}

	LaytonLog(string(data))
	err2 := json.Unmarshal(data, &jsonStruct)
	if err2 != nil {
		LaytonLog(err2.Error())
		return false
	}
	return true
}
