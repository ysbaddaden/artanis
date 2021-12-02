.POSIX:

CRYSTAL = crystal
CRFLAGS =

test: .phony
	$(CRYSTAL) run $(CRFLAGS) test/*_test.cr

bench: .phony
	$(CRYSTAL) run $(CRFLAGS) --release test/*_bench.cr

server: .phony
	$(CRYSTAL) run $(CRFLAGS) --release samples/server.cr

wrk: .phony
	wrk -c 1000 -t 2 -d 5 http://localhost:9292/

.phony:
