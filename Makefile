 test:
	./node_modules/.bin/mocha \
		--compilers coffee:coffee-script \
		-R spec

run:
	supervisor -e "node|js|coffee" run.js
 .PHONY: test run