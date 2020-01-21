package main

import (
	"database/sql"
	"log"
)

//CreateSQL initializes database interface
func CreateSQL() {
	db, err := sql.Open("mysql",
		"root:mangoiscute@/Layton")
	if err != nil {
		log.Fatal(err)
	}
	DB = db
}

//DestroySQL destorys database interface
func DestroySQL() {
	DB.Close()

	DB = nil
}
