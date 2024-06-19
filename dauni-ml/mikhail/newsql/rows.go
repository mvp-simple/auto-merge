package newsql

import (
	"database/sql/driver"
	"fmt"

	"github.com/pkg/errors"
)

type Rows struct {
	rows driver.Rows
}

func NewRows(rows driver.Rows) (driver.Rows, error) {
	if rows == nil {
		return nil, errors.New("rows is nil")
	}

	return &Rows{
		rows: rows,
	}, nil
}

func (a *Rows) Columns() []string {
	fmt.Println("Columns") //nolint:forbidigo

	return a.rows.Columns()
}

func (a *Rows) Close() error {
	fmt.Println("Close") //nolint:forbidigo

	return errors.Wrap(a.rows.Close(), "close")
}

func (a *Rows) Next(dest []driver.Value) error {
	fmt.Println("Next") //nolint:forbidigo

	return errors.Wrap(a.rows.Next(dest), "next")
}
