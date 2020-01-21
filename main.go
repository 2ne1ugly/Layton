package main

import (
	"database/sql"
	"log"
	"net/http"
	"time"

	_ "github.com/go-sql-driver/mysql"
	"github.com/gorilla/mux"
)

//DB : Global variable db interface, can handle concurrent goroutines
var DB *sql.DB

func main() {
	//Init SQL
	LaytonLog("Creating SQL")
	CreateSQL()
	defer DestroySQL()

	//Bind functions
	LaytonLog("Binding functions")
	r := mux.NewRouter()
	BindIdentityHandlers(r)

	//Init Layton
	InitLayton()

	//Define server type
	srv := &http.Server{
		Handler: r,
		Addr:    "127.0.0.1:8000",

		WriteTimeout: 15 * time.Second,
		ReadTimeout:  15 * time.Second,
	}

	LaytonLog("Ready to serve")
	//run server
	err := srv.ListenAndServe()
	if err != nil {
		log.Fatalln(err)
	}
	return
}
