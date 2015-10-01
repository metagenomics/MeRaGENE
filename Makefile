path := PATH=./vendor/python/bin:$(shell echo "${PATH}")

nextflow = "vendor/nextflow"

install: vendor/python

vendor/python: vendor/virtualenv requirements.txt
	mkdir -p log
	python vendor/virtualenv/virtualenv.py $@ --extra-search-dir vendor/virtualenv/virtualenv_support 2>&1 > log/virtualenv.txt
	$(path) pip install -r requirements.txt 2>&1 > log/pip.txt

vendor/virtualenv:
	mkdir -p vendor/virtualenv
	git clone https://github.com/pypa/virtualenv.git $@

test = $(path) nosetests -s --rednose 

feature: vendor/nextflow
	@$(path) behave --stop

test:
	@$(test)

vendor/nextflow:
	mkdir -p $(nextflow)
	curl -fsSL get.nextflow.io --output $(nextflow)/nextflow  
	chmod a+x $(nextflow)/nextflow   

.PHONY: vendor/virtualenv vendor/nextflow test
