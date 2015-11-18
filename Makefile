runner:
	@meteor test-packages --driver-package=practicalmeteor:mocha --port 5000 ./

test:
	@spacejam test-packages --driver-package=practicalmeteor:mocha-console-reporter ./

.PHONY: test runner
