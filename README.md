[![Circle CI](https://circleci.com/gh/metagenomics/bioPipeline/tree/master.svg?style=svg)](https://circleci.com/gh/metagenomics/bioPipeline/tree/master)

### Note! this project is under development (working scripts are provided in the "original" branch)

## Development Guide

This project uses the [GitHub flow](https://guides.github.com/introduction/flow/). The basic idea of the 
this workflow is that the master branch provides always a working version of the project.
Please name your branches accoring to the following pattern:

`type/name`

Where `type` can be `feature` or `fix` and `name` is a short description of the branch.

Example: `feature/development-guide`

Merge this branch by providing a pull request. Please link a corresponding issue to the pull request before merging.

### Development Scripts

The folder `controls` provides a series of scripts to help developers and also
used by the continuous integration server. 

  * `controls/install`: Install required python libraries using virtual env and requirements.txt.

  * `controls/test`: Runs python unit tests (requires previous run of `controls/install`)

### Get started

## Step one
- create a new folder for nextflow to work in 
- switch to this new folder`
- create a blank file, name it "nextflow.config"
- fill it with this code:
    
    params {
    /* your genome-database to search in. */
    GENOME="+ e.g. /vol/genomeDat/test.db+"
    
    /* your blast-database to search in. */
    NCBI="+e.g. /vol/blastDat/blast.db+"
    
    /* numbers of cores to be used executing blast. */
    BLAST_CPU=8

    /* standard programms are used. If you want to use a special version, change the name with its path.
     * e.g. BLASTP="blastp" -> BLASTP="/vol/tools/blast/blastp"
     */
    BLASTP="blastp"

    HMM_SEARCH="hmmsearch"
    HMM_SCAN="hmmscan"
    HMM_PRESS="hmmpress"

    /* numbers of cores to be used executing hmmsearch. */
    HMM_CPU=16

    /* e-value threshold to be used executing hmmsearch. */
    HMM_EVALUE="1e-15"

    /* a folder containig hmm models. All hmm models in this folder are used for searching. */
    INPUT="+ e.g. /vol/project/hmmModels +"

    /*the folder your output is put in*/
    OUTPUT="+ e.g. /vol/project/output +"
    
    /* if you have coverage files, link them here. */
    cov = " e.g. /vol/project/coverage1.txt,/vol/project/coverage2.txt "

    /* if you only have bam files, link them here. They will be converted to coverage files. */
    bam = ""
    }

    manifest {
    homepage = 'https://github.com/metagenomics/bioPipeline'
    description = 'Tool for gene prediction in metagenomics using HMMs.'
    }

## Step two
- open a shell 
- Browse to your project folder containing your nextflow.contig file
- type in "curl -fsSL get.nextflow.io | bash" to download nextflow into this folder
- after nextflow is downloaded, start & download our pipeline with  "./nextflow -C nextflow.config run metagenomics/bioPipeline"
- Thats it ! The pipeline is running and crunching your data. Look for the overview.txt or. overview_new.txt in your output folder after the pipeline is finished
- if you have further questions, search our documentation or contact us via mail