#!/bin/sh 

# This script creates the first version of an overview
# The call should look like this: sh Overview.sh HMM-Hits.unique
# Furthermore this program needs the fasta files and the blastp.txt files,
# therefore you need to be sure these files are in the same directory as the unique HMM-Hits file.
# The output is an overview.txt file in the same directory.
# In this overview file the pubmed analysis is not done in this stage,
# so a continuing programm will overwork it.

# HMM-Hits.unique, where all hits are listed
INPUT=$1

# pathes of other programs which are need to be used
PYTHON="/vol/pathomg/Skripte/createOverview.py"
CREATEFOLDER="/vol/pathomg/Skripte/createFolder.sh"

if [[ ${PWD} == */ ]]
	then
	PWD=${PWD%?}
fi;

sh $CREATEFOLDER $PWD
qsub -e $PWD/error/ -o $PWD/out/ -pe multislot 4 -l vf=8G -cwd -N "overview" -b y python $PYTHON $INPUT