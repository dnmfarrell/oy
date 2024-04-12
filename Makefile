lint:
	shellcheck oy
	shellcheck -x tests/tap.sh -x ./oy tests/run.sh
	shfmt -w oy **/*.sh

test:
	tests/run.sh

.PHONY: lint test
