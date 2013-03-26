mocha = @./node_modules/.bin/mocha \
	--compilers coffee:coffee-script

HEM = @./node_modules/.bin/hem

FILES?=`find ./test -type f -name '*.coffee'`
HOST?=http://localhost
OUTPUT?=host.html

# If PAT is passed in, feed that to mocha. It will only run tests matching that
# pattern.
ifneq ('', PAT)
MOCHA=$(mocha) -g "$(PAT)"
else
MOCHA=$(mocha)
endif

export NODE_PATH=./lib

xunit:
	$(MOCHA) -R xunit $(FILES)

test:
	$(MOCHA) -R spec $(FILES)

debug:
	$(MOCHA) --debug-brk -R spec $(FILES)

watch:
	$(MOCHA) -R dot -w $(FILES)

update:
	@npm install

tags:
	@ctags -R .

deploy:
	@rm -f ./public/application.*
	$(HEM) build
	@sed "s|http://localhost:[0-9]*|$(HOST)|g" ./public/index.html > ./public/$(OUTPUT)
	@s3cmd sync --acl-public ./public/ s3://partners.vistarmedia.com
	@rm -f ./public/application.*
	@rm -f ./public/$(OUTPUT)

.PHONY: test
