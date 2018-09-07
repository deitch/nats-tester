#!/bin/sh

# run tests in async and sync mode
runtests() {
  local name="$1"
  local outdir="$2"

  # replace all / with . 
  name=$(echo $name | sed 's#/#.#g' )
  # and do not start it with a .
  name=${name#.}

  mkdir -p $outdir

  # async mode
  for i in $(seq 1 5); do
    go run examples/stan-bench/main.go -np 1 -ns 0 -n 1000000 -a async.${i} >> $outdir/${name}-async-publish &
    pubpid=$!
    go run examples/stan-bench/main.go -np 0 -ns 1 -n 1000000 -a async.${i} >> $outdir/${name}-async-subscribe &
    subpid=$!
    wait $pubpid
    wait $subpid
  done

  # sync mode
  for i in $(seq 1 5); do
    go run examples/stan-bench/main.go -np 1 -ns 0 -n 1000000 -a sync.${i} >> $outdir/${name}-sync-publish &
    pubpid=$!
    go run examples/stan-bench/main.go -np 0 -ns 1 -n 1000000 -a sync.${i} >> $outdir/${name}-sync-subscribe &
    subpid=$!
    wait $pubpid
    wait $subpid
  done
}

# ensure we have at least one argument
if [ $# -lt 1 ]; then
  echo "Must specific at least one mode to run, memory or path to a disk store"
  exit 1
fi

OUTDIR="output/$(date -u +%Y%m%d-%H%M%S)"
INFOFILE=$OUTDIR/information
mkdir -p $OUTDIR
touch $INFOFILE
date -u >> $INFOFILE
go version >> $INFOFILE
echo "go-nats-streaming $(git -C $GOPATH/src/github.com/nats-io/go-nats-streaming rev-parse --verify HEAD)" >> $INFOFILE
echo "nats-streaming-server $(git -C $GOPATH/src/github.com/nats-io/nats-streaming-server rev-parse --verify HEAD)" >> $INFOFILE

cd $GOPATH/src/github.com/nats-io/go-nats-streaming

for i in $@; do
  if [ "$i" = "memory" ]; then
    # memory mode
    nats-streaming-server -mm 0 -mb 0 &
    natspid=$!
    runtests "memory" "${OUTDIR}"
    # kill the server pid
    kill $natspid
  else
    # disk mode
    rm -rf $i/*
    nats-streaming-server -mm 0 -mb 0 -store file -dir $i &
    natspid=$!
    runtests "$i" "${OUTDIR}"
    # kill the server pid
    kill $natspid
    rm -rf $i/*
  fi

done

# tell where the results are
echo "Results in $OUTDIR"

