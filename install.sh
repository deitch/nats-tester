#!/bin/sh

# is go installed?
if ! which go > /dev/null ; then
  echo "Install go first"
  exit 1
fi

go get -u github.com/nats-io/nats-streaming-server
go get -u github.com/nats-io/go-nats-streaming
cd $GOPATH/src/github.com/nats-io/go-nats-streaming

