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
    And I copy the example data directories:
      | source           | dest        |
      | hmm              | hmm         |  
    When I run the command:
      """
      /homes/pbelmann/bioPipeline/nextflow run ${PWD}/main.nf -profile 'local' --GENOME="${PWD}/tmp/db.faa" --NCBI="${PWD}/tmp/blast.db" --BLAST_CPU=1 --BLASTP="blastp" --HMM_SEARCH="hmmsearch" --HMM_SCAN="hmmscan" --HMM_PRESS="hmmpress" --INPUT="${PWD}/tmp/hmm" --OUTPUT="${PWD}/tmp/output"  --cov="${PWD}/tmp/test.bam.coverage.txt"  --search="${PWD}/tmp/search.yaml"
      """
    Then the exit code should be 0
