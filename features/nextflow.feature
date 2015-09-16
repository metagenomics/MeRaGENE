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
          P="blastp"
        }
        CREATEFOLDER = ""
        HMM {
          SEARCH="hmmsearch"
          SCAN="hmmscan"
          PRESS="hmmpress"
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
      nextflow -C nextflow.config run metagenomics/bioPipeline 
      """
    Then the exit code should be 0
