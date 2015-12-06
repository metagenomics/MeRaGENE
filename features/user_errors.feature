Feature: Test possible user errors.

  Scenario Outline: Run the pipeline with already existing output directory
    Given I create the directory "output"
    And I copy the example data files:
      | source           | dest        |
      | db.faa           | db.faa      |
      | blast.db         | blast.db    |
      | blast.db.phr     | blast.db.phr|
      | blast.db.psq     | blast.db.psq|
      | blast.db.pin     | blast.db.pin|
      | search.yaml      | search.yaml |
      | keywords.txt     | keywords.txt|
    And I copy the example data directories:
      | source           | dest        |
      | hmm              | hmm         |
    When I run the command:
      """
      ${NEXTFLOW}/nextflow run ${PWD}/main.nf -profile 'local' \
      <output>
      """
    Then the exit code should be 0
    And the stdout should contain:
      """
      Please remove it or assign another output directory.
      """
    Examples:
      | output                         |
      | --output="${PWD}/tmp/output"   |
      | --output="output"              |