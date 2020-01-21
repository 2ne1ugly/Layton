package main

import (
	"log"
	"net/http"
	"time"

	"github.com/gorilla/mux"
	_ "github.com/lib/pq"
)

func main() {
	//Init SQL
	LaytonLog("Setting up SQL")
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
		Addr:    "10.10.151.75:8000",

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
