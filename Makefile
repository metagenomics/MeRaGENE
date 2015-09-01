path := PATH=./vendor/python/bin:$(shell echo "${PATH}")

install: vendor/python

vendor/python: vendor/virtualenv requirements.txt script/nextflow
	mkdir -p log
	python vendor/virtualenv/virtualenv.py $@ --extra-search-dir vendor/virtualenv/virtualenv_support 2>&1 > log/virtualenv.txt
	$(path) pip install -r requirements.txt 2>&1 > log/pip.txt

vendor/virtualenv:
	mkdir -p vendor/virtualenv
	git clone https://github.com/pypa/virtualenv.git $@

script/nextflow:
	cd scripts && wget -qO- get.nextflow.io | bash         

test = $(path) nosetests -s --rednose 

test:
	@$(test)

.PHONY: vendor/virtualenv test
