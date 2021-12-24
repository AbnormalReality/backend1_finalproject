# в мэйке 5 вирт целей: run - сборка и запуск/ build - сборка бинарника/ linters - запуск линтеров
# pre-commit по конфигурации и запусе тестов
LOCAL_BIN=$(CURDIR)/bin
GIT_COMMIT=$(shell git rev-list -1 HEAD)

# build and run
.PHONY: run
run:
	go run ./...

# build binary
.PHONY: build
build:
    mkdir -p $(LOCAL_BIN)
	go build  ./...

# run linters
.PHONY: lint
lint:
	golangci-lint run ./...
	pre-commit run --verbose

# pre-commit hooks
.PHONY: pre-commit
pre-commit:
	pre-commit install

# run tests
.PHONY: test
test:
	go test -count=1 -cover ./...

.DEFAULT_GOAL := run