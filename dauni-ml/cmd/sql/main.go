package main

import (
	"fmt"

	"github.com/lib/pq"

	"github.com/rinatusmanov/dauni-ml/mikhail/newsql"
)

func main() {
	fmt.Println("qwasdasd", pq.Driver{}, newsql.NewStmt(nil)) //nolint:forbidigo
}
