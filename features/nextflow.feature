Feature: Verification steps for bioPipeline

  Scenario: Run the pipeline with valid parameters
    Given I create the directory "output"
    And I copy the example data files:
      | source           | dest        |
      | db.faa           | db.faa      |  
      | blast.db         | blast.db    |
      | blast.db.phr     | blast.db.phr|
      | blast.db.psq     | blast.db.psq| 
      | blast.db.pin     | blast.db.pin|
      | test.bam.coverage.txt |test.bam.coverage.txt | 
    And I copy the example data directories:
      | source           | dest        |
      | hmm              | hmm         |  
    When I run the command:
      """
      nextflow run /home/ubuntu/nextflow  -profile 'local' --GENOME="/home/ubuntu/bioPipeline/tmp/db.faa" --NCBI="/home/ubuntu/bioPipeline/tmp/blast.db" --BLAST_CPU=1 --BLASTP="blastp" --HMM_SEARCH="hmmsearch" --HMM_SCAN="hmmscan" --HMM_PRESS="hmmpress" --INPUT="/home/ubuntu/bioPipeline/tmp/hmm" --OUTPUT="/home/ubuntu/bioPipeline/tmp/output"  --cov="/home/ubuntu/bioPipeline/tmp/test.bam.coverage.txt"
      """
    Then the exit code should be 0
