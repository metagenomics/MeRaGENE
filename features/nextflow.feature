Feature: Verification steps for bioPipeline

  Scenario: Run the pipeline with valid parameters
    Given I copy the example data files:
      | source           | dest        |
      | db.faa           | db.faa      |  
      | blast.db         | blast.db    |
      | blast.db.phr     | blast.db.phr|
      | blast.db.psq     | blast.db.psq| 
      | blast.db.pin     | blast.db.pin|
      | test.bam.coverage.txt |test.bam.coverage.txt | 
      | search.yaml      | search.yaml |
      | keywords.txt     | keywords.txt|
    And I copy the example data directories:
      | source           | dest        |
      | hmm              | hmm         |  
    When I run the command:
      """
      ${NEXTFLOW}/nextflow run ${PWD}/main.nf -profile 'local' --genome="${PWD}/tmp/db.faa" --ncbi="${PWD}/tmp/blast.db" --blast_cpu=1 --blastp="blastp" --hmm_search="hmmsearch" --hmm_scan="hmmscan" --hmm_press="hmmpress" --input="${PWD}/tmp/hmm" --output="${PWD}/tmp/output"  --cov="${PWD}/tmp/test.bam.coverage.txt"  --search="${PWD}/tmp/search.yaml"  --keywords="${PWD}/tmp/keywords.txt"
      """
    Then the exit code should be 0
    And the following files should exist and not be empty:
      | file                     |
      | output/overview.html     |
      | output/overview_new.txt  |
    And the file "output/overview_new.txt" should contain 6 lines

