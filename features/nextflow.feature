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
      nextflow pull metagenomics/bioPipeline
      """
    Then the exit code should be 0
