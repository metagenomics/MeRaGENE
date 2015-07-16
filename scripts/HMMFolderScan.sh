#!/bin/sh

#$ -S /bin/sh
#$ -N HMMFolderScan
#############################################################################################
# Program call sh HMMFolderScan.sh <EValue> <input Folder> <output Folder>
# Has to be executed on linux machine !!
# Script to build hmm Databse to be scanned for sequences.
# All *.hmm files present inside the input folder will be cat together to form new database.
# These database will be scanned for Plant1234DNA12_k31_gt1kb genes.
#############################################################################################

# Script & Database paths
HMMSEARCH="/vol/biotools/bin/hmmsearch"
HMMSCAN="/vol/biotools/bin/hmmscan"
HMMPRESS="/vol/biotools/bin/hmmpress"
CREATEFOLDER="/vol/pathomg/Skripte/createFolder.sh"
DATABASE="/vol/pathomg/DB/Plant1234DNA12_k31_gt1kb_genes.faa"
CPU=16
EVALUE=$1
IN=$2
OUT=$3

# if arguments to ensure a correct execution
if [ $# -le 2 ]
  then
    echo "Wrong number of arguments."
    echo "To execute write: sh HMMFolderScan.sh <E-Value> <HMM-folder> <output folder>"

  elif [ -z "$2" ]
  then
    echo "Input path missing"
  elif [ -z "$3" ]
  then 
    echo "Output path missing"
  else

# If call to ensure the right input string format. If the last character is a / it is cut off.
if [[ ${IN} == */ ]]
	then
		IN=${IN%?}
fi;

# If call to ensure the right input string format. If the last character is a / it is cut off.
if [[ ${OUT} == */ ]]
	then
		OUT=${OUT%?}
fi;

# Warnings if input is incorrect.
if [ $# -le 2 ]
  then
    echo "Wrong number of arguments."
    echo "Write sh HMMFolderScan.sh <EValue> <input Folder> <output Folder>"
    echo "EValue Format = 1e-5 . If no EValue is needed write \"\""
    echo "All HMMs you would like to scan, have to be present inside the input folder. (Format = *.hmm)"

  elif [ -z "$1" ]
  then
    echo "Input amount missing"
  elif [ -z "$2" ]
  then
    echo "Input path missing"
  elif [ -z "$3" ]
  then 
    echo "Output path missing"
  elif [ "$(uname)" != "Linux" ]
	then
	
		echo "Please run again on linux machine"

	else
		# All HMM files inside the input folder are merged to one big HMM file inside the output folder.
		cat $IN/*.hmm > $OUT/all.hmm
		# New HMM Databse needs to be indexed and precomputed for HMMScan to work. 
		$HMMPRESS $OUT/all.hmm
		# Pipeline Folders are created with the help of a subscript.
		sh $CREATEFOLDER $OUT
		# If EValue is given, it is used in qsub call.
		if [ "$EVALUE" != "" ]; then
			EVALUE="-E $EVALUE"	
		fi; 
		#HMMScan qsub grid call.
		qsub -b y -pe multislot $CPU -N "HMMScan" -l vf=4G -l arch=lx24-amd64 -e $OUT/error/ -o $OUT/out/ -cwd $HMMSCAN $EVALUE --domtblout $OUT/all.domtblout --cpu $CPU -o $OUT/all.out $OUT/all.hmm $DATABASE
 
fi;

fi;