.PHONY: test bench server wrk

CRYSTAL_BIN ?= crystal

test:
	$(CRYSTAL_BIN) test/*_test.cr

bench:
	$(CRYSTAL_BIN) run --release test/*_bench.cr

server:
	$(CRYSTAL_BIN) run --release samples/server.cr

wrk:
	wrk -c 1000 -t 2 -d 5 http://localhost:9292/
