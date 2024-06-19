FROM usmanovrinat1984/compiler_go_ibm_db
CMD CGO_ENABLED=1 GOOS=linux GOARCH=amd64 go run ./check/check_driver.go