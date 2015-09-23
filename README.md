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

### Quick start

- create a new folder for nextflow to work in 
- switch to this new folder
- open a shell 
- type in `"curl -fsSL get.nextflow.io | bash"` to download nextflow into this folder
- after nextflow is downloaded, replace all the `"YOUR_***"` parts in the following command with your own paths 
  - `"./nextflow run main.nf --GENOME="YOUR_METAGENOME" --NCBI="YOUR_BLAST-DB" --INPUT="YOUR_INPUT-HMM_FOLDER" --OUTPUT="YOUR_OUTPUT-FOLDER" --cov="COVERAGE_FILES"`
- After replacing everything, run your command
- Thats it ! The pipeline is running and crunching your data. Look for the overview.txt or. overview_new.txt in your output folder after the pipeline is finished
- if you have further questions, search our documentation or contact us via mail
