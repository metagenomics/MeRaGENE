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
