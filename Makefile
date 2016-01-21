TESTS=$(shell ls test/*.rb)

test:
	ruby -W1 .gs/bin/cutest $(TESTS)

.PHONY: test