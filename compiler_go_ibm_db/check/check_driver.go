package main

import (
	"context"
	"database/sql"
	"fmt"
	_ "github.com/ibmdb/go_ibm_db"
	"time"
)

func main() {
	fmt.Println("Begin test program")
	defer fmt.Println("End test program")
	con := "HOSTNAME=host;DATABASE=name;PORT=number;UID=username;PWD=password"
	db, err := sql.Open("go_ibm_db", con)
	if err != nil {
		panic(err)
	}
	ctx, cancel := context.WithTimeout(context.Background(), time.Second)
	fmt.Println(db.PingContext(ctx))
	cancel()
	_ = db.Close()
}
