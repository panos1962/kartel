all:
	@:

.PHONY: status
status:
	@git status

.PHONY: commit
commit:
	@git commit -m "modifications" .; :

.PHONY: push
push:
	@hg push; :

.PHONY: git
git:
	@(make -s commit && make push)
	@ echo '#########################################'
	@(make -s commit && make push)

.PHONY: cmp
cmp:
	@hg diff --stat

.PHONY: diff
diff:
	@hg diff

.PHONY: pull
pull:
	@hg pull --update

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
