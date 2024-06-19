package newsql

import (
	"database/sql/driver"
	"fmt"

	"github.com/pkg/errors"
)

type Result struct {
	result driver.Result
}

func NewResult(result driver.Result) (driver.Result, error) {
	if result == nil {
		return nil, errors.New("result is nil")
	}

	return &Result{
		result: result,
	}, nil
}

func (a *Result) LastInsertId() (int64, error) {
	fmt.Println("LastInsertId") //nolint:forbidigo

	insertID, err := a.result.LastInsertId()
	if err != nil {
		return 0, errors.Wrap(err, "last insert insertID")
	}

	return insertID, nil
}

func (a *Result) RowsAffected() (int64, error) {
	fmt.Println("RowsAffected") //nolint:forbidigo

	idRows, err := a.result.RowsAffected()
	if err != nil {
		return 0, errors.Wrap(err, "rows affected")
	}

	return idRows, nil
}
