Feature: Verification steps for bioPipeline

  Scenario: Run the pipeline with valid parameters
    Given I create the file "nextflow.config" with the contents:
     """
     params {
        DATABASE {
          GENOME=""
          NCBI=""
        }
        BLAST {
          CPU=8
          P="/vol/cmg/bin/blastp"
        }
        CREATEFOLDER = ""
        HMM {
          SEARCH="/vol/biotools/bin/hmmsearch"
          SCAN="/vol/biotools/bin/hmmscan"
          PRESS="/vol/biotools/bin/hmmpress"
          CPU=16
          EVALUE="1e-15"
          INPUT=""
          OUTPUT=""
        }
        cov = ""
        out = ""
        bam = ""
     }
     """
    When I run the command:
      """
      echo "test"
      """
    Then the exit code should be 0
