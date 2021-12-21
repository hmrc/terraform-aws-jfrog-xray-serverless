# NB - You'll need to run the Makefile with AWS authentication (aws-vault or aws-profile) for the account you wish to run the tests in.
# This will fail without it.

.PHONY: test
test:
	cd test && go test -v -timeout 30m