path := PATH=./vendor/python/bin:$(shell echo "${PATH}")

install: vendor/python

vendor/python: vendor/virtualenv requirements.txt
	mkdir -p log
	virtualenv $@ --extra-search-dir vendor/virtualenv/virtualenv_support 2>&1 > log/virtualenv.txt
	$(path) pip install -r requirements.txt 2>&1 > log/pip.txt

vendor/virtualenv:
	mkdir -p vendor/virtualenv
	git clone https://github.com/pypa/virtualenv.git $@

.PHONY: vendor/virtualenv
