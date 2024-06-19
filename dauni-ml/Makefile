APP_NAME ?= ep

DIR:=$(patsubst %/,%,$(dir $(abspath $(lastword $(MAKEFILE_LIST)))))

LOCAL_BIN:=$(DIR)/bin
GEN_CLAY_BIN:=$(DIR)/bin/protoc-gen-goclay
export GEN_CLAY_BIN
MINIMOCK_BIN:=$(DIR)/bin/minimock
export MINIMOCK_BIN
MOCKGEN_BIN:=$(DIR)/bin/mockgen
export MOCKGEN_BIN
GEN_GO_BIN:=$(DIR)/bin/protoc-gen-go
export GEN_GO_BIN
GEN_GOFAST_BIN:=$(DIR)/bin/protoc-gen-gofast
export GEN_GOFAST_BIN
GEN_GOGOFAST_BIN:=$(DIR)/bin/protoc-gen-gogofast
export GEN_GOGOFAST_BIN

protoc-build:
	$(info #Installing binary dependencies...)
	GOBIN=$(LOCAL_BIN) go install -mod=readonly github.com/utrack/clay/v2/cmd/protoc-gen-goclay@v2.4.9
	GOBIN=$(LOCAL_BIN) go install -mod=readonly github.com/golang/protobuf/protoc-gen-go@v1.5.2
	GOBIN=$(LOCAL_BIN) go install -mod=readonly github.com/gogo/protobuf/protoc-gen-gofast@v1.3.2
	GOBIN=$(LOCAL_BIN) go install -mod=readonly github.com/gogo/protobuf/protoc-gen-gogofast@v1.3.2
	GOBIN=$(LOCAL_BIN) go install -mod=readonly github.com/golang/mock/mockgen@v1.6.0

generate-mocks:
#	rm -rf ./internal/app/audit/mock
#	rm -rf ./internal/app/object/mock
#	rm -rf ./internal/app/role/mock
#	rm -rf ./internal/app/user/mock
#	rm -rf ./internal/app/audit_logger/mock
#	${MOCKGEN_BIN} -source=./internal/app/audit/repository/repository.go -destination=./internal/app/audit/mock/repository.go -package=mock
#	${MOCKGEN_BIN} -source=./internal/app/audit_logger/entry_template.go -destination=./internal/app/audit_logger/mock/entry_template.go -package=mock
#	${MOCKGEN_BIN} -source=./internal/app/object/repository/repository.go -destination=./internal/app/object/mock/repository.go -package=mock
#	${MOCKGEN_BIN} -source=./internal/app/role/repository/repository.go -destination=./internal/app/role/mock/repository.go -package=mock
#	${MOCKGEN_BIN} -source=./internal/app/user/repository/repository.go -destination=./internal/app/user/mock/repository.go -package=mock

generate: #protoc-build generate-mocks
	protoc --plugin=protoc-gen-goclay=$(GEN_CLAY_BIN) --plugin=protoc-gen-gofast=$(GEN_GOFAST_BIN) \
    		-I/usr/local/include:proto:proto_master:proto_master/third_party/googleapis:./vendor.pb:. \
    		--gofast_out=plugins=grpc:.. proto/types.proto;
	for fileName in $(shell find ./proto -type f -exec basename {} \; | egrep -v types ); do\
		dirName=$${fileName//.proto/}; \
		rm -Rf ./vendor.pb/$${dirName} ; \
		mkdir -p ./vendor.pb/$${dirName}; \
		protoc --plugin=protoc-gen-goclay=$(GEN_CLAY_BIN) --plugin=protoc-gen-gofast=$(GEN_GOFAST_BIN) \
		-I/usr/local/include:proto:proto_master:proto_master/third_party/googleapis:./vendor.pb:. \
		--gofast_out=plugins=grpc:.. \
		--goclay_out=../ proto/$${fileName}; \
	done

.PHONY: golangci-lint
golangci-lint:
	if [ -z "$(shell which gosimports)" ]; then \
		go install github.com/daixiang0/gci@latest ; \
	fi

	for file in $(shell find . -not -path ./vendor/\* -name "*.go"); do \
		$(shell go env GOPATH)/bin/gci write -s standard -s default -s "Prefix(github.com/rinatusmanov/dauni-ml)" $$file ; \
	done

	if [ -z "$(shell which golangci-lint)" ]; then \
		curl -sSfL https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh | \
		 sh -s -- -b $(shell go env GOPATH)/bin; \
	fi
	golangci-lint version
	golangci-lint  --color always -v run --timeout 5m



