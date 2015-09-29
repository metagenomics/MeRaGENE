[![Circle CI](https://circleci.com/gh/metagenomics/MeRaGENE/tree/master.svg?style=svg)](https://circleci.com/gh/metagenomics/MeRaGENE/tree/master)

# **MeRaGENE**

### Introduction

MeRaGENE (Metagenomics rapid gene identification pipeline) is based on profile Hidden-Markov-Models (pHMM) which can be build from any gene set. Furthermore it allows to scale on a single multicore machine and also on different cluster systems. MeRaGENE first scans the metagenome dataset for similarities to the predefined pHMMs. To verify the identified hits, a BLASTp search on the NCBI nr database is performed. Multiple settings like E-value thresholds, gene coverage, etc. are tested to further enhance the reliability of identified hits.
Finally, all results are summarized in one HTML file and visualized in charts. This allows to explore results easier and thereby optimizes the interpretation of findings.

**MeRaGENE** produces results like the following example:
http://metagenomics.github.io/MeRaGENE/

### Quickstart

- create a new folder for nextflow to work in 
- switch to this new folder
- create a new .txt document
- fill it with keywords, one word per line.
  publications associated with your blast hits will be scanned for these keywords
- open a shell 
- type in `"curl -fsSL get.nextflow.io | bash"` to download nextflow into this folder
- after nextflow is downloaded, replace all the `"YOUR_***"` parts in the following command with your own paths 
  - `"./nextflow run main.nf --genome="YOUR_METAGENOME" --ncbi="YOUR_BLAST-DB" --input="YOUR_INPUT-HMM_FOLDER" --output="YOUR_OUTPUT-FOLDER" --cov="COVERAGE_FILES" --keywords="YOUR_KEYWORD-FILE"`
- after replacing everything, run your command
- that's it ! The pipeline is running and crunching your data. Look for the overview.txt or. overview_new.txt in your output folder after the pipeline is finished
- if you have further questions:
   - read the additional settings section down below 
   - search our documentation 
   - contact us via mail

### Additional settings

 If you want/have to make further changes to your pipeline, here are all possibilities:
 
 ```Shell
    /* Your genome-database to search in. */
    --genome="e.g. /vol/genomeDat/test.db"
    
    /* Your blast-database to search in. */
    --ncbi="e.g. /vol/blastDat/blast.db"
    
    /* Numbers of cores to be used executing blast. */
    --blast_cpu=8

    /* Standard programs are used. If you want to use a special version, change the name with its path.
     * e.g. blastp="blastp" -> blastp="/vol/tools/blast/blastp"
     */
    --blastp="blastp"
    --hmm_search="hmmsearch"
    --hmm_scan="hmmscan"
    --hmm_press="hmmpress"

    /* Numbers of cores to be used executing hmmsearch. */
    --hmm_cpu=16

    /* E-value threshold to be used executing hmmsearch. */
    --hmm_evalue="1e-15"

    /* A folder containing hmm models. All hmm models in this folder are used for searching. */
    --input="e.g. /vol/project/hmmModels"

    /*A folder path that the pipeline should produce. */
    --output="e.g. /vol/project/output"
    
    /* If you have coverage files, link them here. */
    --cov = "e.g. /vol/project/coverage1.txt,/vol/project/coverage2.txt"

    /* If you only have bam files, link them here. They will be converted to coverage files. */
    --bam = "e.g. /vol/project/metaGen.bam"
    
    /* If you want your results grouped, group them using a first level .yaml file. 
     * If you have downloaded MeRaGENE, you can look at the example file features/data/search.yaml
     */
    --search="e.g. /vol/project/search.yaml" 

    /* A text file, filled with one word per line. 
     * publications associated with your blast hits will be scanned for these keywords.
     */
    --keywords="e.g. /vol/project/keywords.txt"
```

### E-Mail
Contact us, if you have further questions:
`pbelmann@cebitec.uni-bielefeld.de`

## Development Guide

This project uses the [GitHub flow](https://guides.github.com/introduction/flow/). The basic idea of the 
this workflow is that the master branch provides always a working version of the project.
Please name your branches according to the following pattern:

`type/name`

Where `type` can be `feature` or `fix` and `name` is a short description of the branch.

Example: `feature/development-guide`

Merge this branch by providing a pull request. Please link a corresponding issue to the pull request before merging.

### Development Scripts

The folder `controls` provides a series of scripts to help developers and also
used by the continuous integration server. 

  * `controls/install`: Install required python libraries using virtual env and requirements.txt.

  * `controls/test`: Runs python unit tests (requires previous run of `controls/install`)
  
  * `controls/feature`: Runs feature tests (requires previous run of `controls/install`) 
  
