runner:
	@TEST_WATCH=1 meteor test-packages --driver-package=meteortesting:mocha --port 5001 ./

test:
	@meteor test-packages --driver-package=meteortesting:mocha --once --port 5001 ./

.PHONY: test runner
