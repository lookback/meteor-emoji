PORT=5010

runner:
	@TEST_WATCH=1 meteor test-packages --driver-package=meteortesting:mocha --port $(PORT) ./

test:
	@meteor test-packages --driver-package=meteortesting:mocha --once --port $(PORT) ./

.PHONY: test runner
