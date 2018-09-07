# NATS performance testing
This is a basic set of tools to run performance testing of NATS with the following formats:

* memory (async and sync)
* nand drive (async and sync)
* Optane drive (async and sync)

Results will be in the `output/` directory, with a subdirectory named for the current date of the tests.

To install:

1. Ensure [go](https://golang.org) is installed
2. Mount the drives you want to test in various paths, e.g. `/mnt/nand`
3. Run [install.sh](./install.sh)
4. Run [run.sh](./run.sh)

Run `run.sh` with arguments for the type of testing. `memory` means to test memory. Anything with an absolute path is the path to store on-disk.
The output files will use the name of the type, e.g. `memory-async-publish`. File path characters `/` will be replaced with `_`.

E.g.

```
run.sh memory /mnt/optane/datastore /mnt/nand/datastore
```

