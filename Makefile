
PYTHON = python
PANDOC = pandoc
PYLINT = pylint

EMAIL = "mahtin@mahtin.com"
NAME = "cloudflare"

all:	README.rst CHANGELOG.md build

README.rst: README.md
	$(PANDOC) --from=markdown --to=rst < README.md > README.rst 

CHANGELOG.md: FORCE
	@ tmp=/tmp/_$$$$.md ; \
	( \
		cp /dev/null $$tmp ; \
		echo '# Change Log' ; \
		echo '' ; \
		git log --date=iso-local --pretty=format:' - %ci [%h](https://github.com/cloudflare/python-cloudflare/commit/%H) %s' ; \
		echo '' ; \
	)  >> $$tmp ; \
	diff $$tmp CHANGELOG.md || ( cp $$tmp CHANGELOG.md ; echo "CHANGELOG.md - updated" ) ; \
	rm $$tmp
FORCE:

build: setup.py
	$(PYTHON) setup.py -q build

install: build
	sudo $(PYTHON) setup.py -q install
	sudo rm -rf ${NAME}.egg-info

test: all
#	 to be done

sdist: all
	make clean
	make test
	$(PYTHON) setup.py -q sdist
	@rm -rf ${NAME}.egg-info

bdist: all
	make clean
	make test
	$(PYTHON) setup.py -q bdist
	@rm -rf ${NAME}.egg-info

upload: clean all tag upload-pypi upload-github

upload-pypi:
	$(PYTHON) setup.py -q sdist upload --sign --identity="$(EMAIL)"

upload-github:
	git push origin --tags

showtag: sdist
	@ v=`ls -r dist | head -1 | sed -e 's/cloudflare-\([0-9.]*\)\.tar.*/\1/'` ; echo "\tDIST VERSION =" $$v ; (git tag | fgrep -q "$$v") && echo "\tGIT TAG EXISTS"

tag: sdist
	@ v=`ls -r dist | head -1 | sed -e 's/cloudflare-\([0-9.]*\)\.tar.*/\1/'` ; echo "\tDIST VERSION =" $$v ; (git tag | fgrep -q "$$v") || git tag "$$v"

lint:
	$(PYLINT) CloudFlare cli4

clean:
	rm -rf build
	rm -rf dist
	mkdir build dist
	$(PYTHON) setup.py -q clean
	rm -rf ${NAME}.egg-info

