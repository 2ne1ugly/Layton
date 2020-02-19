package main

import (
	"io/ioutil"
	"log"

	"github.com/jmoiron/sqlx"
)

//DB : Global variable db interface, can handle concurrent goroutines
var db *sqlx.DB

//CreateSQL initializes database interface
func CreateSQL() {
	data, _ := ioutil.ReadFile("pwd")

	dbb, err := sqlx.Connect("postgres", string(data))
	if err != nil {
		log.Fatal(err)
	}
	// _, err = db.Query("USE layton")
	// if err != nil {
	// 	log.Fatal(err)
	// }
	db = dbb
}

//DestroySQL destorys database interface
func DestroySQL() {
	db.Close()

	db = nil
}
