APP=$(shell basename $(shell git remote get-url origin))
REGISTRY=alkozp
VERSION=$(shell git describe --tags --abbrev=0)-$(shell git rev-parse --short HEAD)
TARGETOS=linux #darwin windows
TARGETARCH=amd64 #arm64

.PHONY: format lint test get build image push clean linux darwin windows amd64 arm64

format:
	gofmt -s -w ./

lint:
	golint

test:
	go test -v

get:
	go get

linux:
	@TARGETOS=linux
	@TARGETARCH=amd64
	CGO_ENABLED=0 GOOS=${TARGETOS} GOARCH=${TARGETARCH} go build -v -o kbot -ldflags "-X="github.com/alkozp/kbot/cmd.appVersion=${VERSION}
darwin:
	@TARGETOS=darwin
	@TARGETARCH=amd64
	CGO_ENABLED=0 GOOS=${TARGETOS} GOARCH=${TARGETARCH} go build -v -o kbot -ldflags "-X="github.com/alkozp/kbot/cmd.appVersion=${VERSION}
darwin_arm64:
	@TARGETOS=darwin
	@TARGETARCH=arm64
	CGO_ENABLED=0 GOOS=${TARGETOS} GOARCH=${TARGETARCH} go build -v -o kbot -ldflags "-X="github.com/alkozp/kbot/cmd.appVersion=${VERSION}
windows:
	@TARGETOS=windows
	@TARGETARCH=amd64
	CGO_ENABLED=0 GOOS=${TARGETOS} GOARCH=${TARGETARCH} go build -v -o kbot -ldflags "-X="github.com/alkozp/kbot/cmd.appVersion=${VERSION}


# default os:linux arch:amd64
build: format get
	CGO_ENABLED=0 GOOS=${TARGETOS} GOARCH=${TARGETARCH} go build -v -o kbot -ldflags "-X="github.com/alkozp/kbot/cmd.appVersion=${VERSION}

image:
	docker build . -t ${REGISTRY}/${APP}:${VERSION}-${TARGETARCH} --build-arg TARGETOS=${TARGETOS} --build-arg TARGETARCH=${TARGETARCH}

push:
	docker push ${REGISTRY}/${APP}:${VERSION}-${TARGETARCH}

clean:
	rm -rf kbot*
	docker rmi ${REGISTRY}/${APP}:${VERSION}-${TARGETARCH}