package newsql

import (
	"context"
	"database/sql/driver"
	"fmt"

	"github.com/pkg/errors"
)

type Stmt struct {
	stmt             driver.Stmt
	stmtExecContext  driver.StmtExecContext
	stmtQueryContext driver.StmtQueryContext
}

func NewStmt(stmt driver.Stmt) *Stmt {
	var (
		stmtExecContext  driver.StmtExecContext
		stmtQueryContext driver.StmtQueryContext
	)

	if v, ok := stmt.(driver.StmtExecContext); ok {
		stmtExecContext = v
	}

	if v, ok := stmt.(driver.StmtQueryContext); ok {
		stmtQueryContext = v
	}

	return &Stmt{
		stmt:             stmt,
		stmtExecContext:  stmtExecContext,
		stmtQueryContext: stmtQueryContext,
	}
}

func (m *Stmt) QueryContext(ctx context.Context, args []driver.NamedValue) (driver.Rows, error) {
	var (
		rows driver.Rows
		err  error

		localCtx, cancel = context.WithCancel(context.Background())
	)

	go func() {
		values := make([]driver.Value, len(args))

		for index, arg := range args {
			values[index] = arg.Value
		}

		rows, err = m.stmt.Query(values) //nolint:staticcheck

		cancel()
	}()

	select {
	case <-ctx.Done():
		return nil, errors.Wrap(ctx.Err(), "context is done")
	case <-localCtx.Done():
		if err != nil {
			return nil, errors.Wrap(err, "query local context")
		}

		return NewRows(rows)
	}
}

func (m *Stmt) ExecContext(ctx context.Context, args []driver.NamedValue) (driver.Result, error) {
	var (
		result driver.Result
		err    error

		localCtx, cancel = context.WithCancel(context.Background())
	)

	go func() {
		argsValues := make([]driver.Value, len(args))

		for index, arg := range args {
			argsValues[index] = arg.Value
		}

		result, err = m.stmt.Exec(argsValues) //nolint:staticcheck

		cancel()
	}()

	select {
	case <-ctx.Done():
		return nil, errors.Wrap(ctx.Err(), "context is done")
	case <-localCtx.Done():
		if err != nil {
			return nil, errors.Wrap(err, "exec context")
		}

		return NewResult(result)
	}
}

func (m *Stmt) Close() error {
	fmt.Println("Close") //nolint:forbidigo

	return errors.Wrap(m.stmt.Close(), "close stmt")
}

func (m *Stmt) NumInput() int {
	fmt.Println("NumInput") //nolint:forbidigo

	return m.stmt.NumInput()
}

func (m *Stmt) Exec(args []driver.Value) (driver.Result, error) {
	fmt.Println("Exec") //nolint:forbidigo

	result, err := m.stmt.Exec(args) //nolint:staticcheck
	if err != nil {
		return nil, errors.Wrap(err, "exec")
	}

	return NewResult(result)
}

func (m *Stmt) Query(args []driver.Value) (driver.Rows, error) {
	fmt.Println("Query") //nolint:forbidigo

	rows, err := m.stmt.Query(args) //nolint:staticcheck
	if err != nil {
		return nil, errors.Wrap(err, "query")
	}

	return NewRows(rows)
}
