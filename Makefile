lint:
	shellcheck oy
	shellcheck -x tests/tap.sh -x ./oy tests/run.sh
	shfmt -w oy **/*.sh
	perl -ni -e 'print unless /^ /' README.md && ./oy h | sed 's/^/    /' >> README.md

test:
	tests/run.sh

.PHONY: lint test
