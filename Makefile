.PHONY: test
test:
	crystal test/*_test.cr

.PHONY: bench
bench:
	crystal run --release test/*_bench.cr

.PHONY: server
server:
	crystal run --release samples/server.cr

.PHONY: wrk
wrk:
	wrk -c 1000 -t 1 -d 30 http://localhost:9292/
