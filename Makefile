all:
	@:

.PHONY: status
status:
	@git status .

.PHONY: diff
diff:
	@git diff .

.PHONY: add
add:
	@git add --verbose .

.PHONY: commit
commit:
	@git commit --message "modifications" .; :

.PHONY: push
push:
	@git push

.PHONY: git
git:
	@(make -s commit && make push)
	@ echo '#########################################'
	@(make -s commit && make push)

.PHONY: pull
pull:
	@git pull

.PHONY: install
install: jsmin local/install.cf
	@#sudo install/install `cat local/install.cf`

.PHONY: test
test:
	@(cd local && bash test.sh)

.PHONY: www
www: jsmin

JSMIN_SOURCES = `find www -name '*.js' | grep -v '\.min\.js\>'`
JSMIN_OPTS = -q -p -s

.PHONY: jsmin
jsmin:
	@pd_jsmin $(JSMIN_OPTS) $(JSMIN_SOURCES)

.PHONY: cleanup
cleanup:
	@find . -name '*.min.js' -exec rm -f {} \;
