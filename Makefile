path := PATH=./vendor/python/bin:$(shell echo "${PATH}")

nextflow = "vendor/nextflow"

install: vendor/python

vendor/python: vendor/virtualenv requirements.txt
	mkdir -p log
	python vendor/virtualenv/virtualenv.py $@ --extra-search-dir vendor/virtualenv/virtualenv_support 2>&1 > log/virtualenv.txt
	$(path) pip install -r requirements.txt 2>&1 > log/pip.txt

vendor/virtualenv:
	mkdir -p vendor/virtualenv
	curl -L https://github.com/pypa/virtualenv/archive/13.1.2.tar.gz |  tar xz  --strip-components=1 --directory $@

test = $(path) nosetests -s --rednose 

feature: vendor/nextflow
	rm -rf tmp/output
	@$(path) behave --stop

test:
	@$(test)

vendor/nextflow:
	mkdir -p $(nextflow)
	curl -fsSL get.nextflow.io --output $(nextflow)/nextflow  
	chmod a+x $(nextflow)/nextflow   

.PHONY: vendor/nextflow test
