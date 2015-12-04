Feature: Test possible user errors.

  Scenario Outline: Run the pipeline with already existing output directory
    Given I create the directory "output"
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