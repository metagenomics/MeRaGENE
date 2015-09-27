#!/bin/sh
# Script to search for specific keywords in pubmed abstracts provieded by ncbi link inputs.
# The .acc input file should contain links like this http://www.ncbi.nlm.nih.gov/protein/WP_012738633
# Hits are saved in a all.pubhits file.
# FoldertoPubmed.sh needs to be within the same folder as UrltoPubmedID, which is used in this script.

INPUT=$1
OUTPUT=$2
URLTOPUBMEDID=$3
KEYWORDS=$4

# if arguments to ensure a correct execution
if [ $# -le 1 ]
  then
    echo "Wrong number of arguments."
    echo "To execute write: sh FoldertoPubmed.sh <input folder> <output folder>"

  elif [ -z "$1" ]
  then
    echo "Input path missing"
  elif [ -z "$2" ]
  then
    echo "Output path missing"
  else

# Cut all paths to the same format, no / at the end.
if [[ ${INPUT} == */ ]]
	then
	INPUT=${INPUT%?}
fi;

# Cut all paths to the same format, no / at the end.
if [[ ${OUTPUT} == */ ]]
	then
	OUTPUT=${OUTPUT%?}
fi;

# create folder to save acc files in case of an error
mkdir $OUTPUT/acc_files

# invoce the pubmed script with all .acc files 
for file in $INPUT/*.acc
do 
	REALP=$(realpath $file)
	sh $URLTOPUBMEDID $REALP $OUTPUT/  $KEYWORDS
done

# create an overview out of all single .pubhit files 
cat $OUTPUT/*.pubhit > $OUTPUT/all.pubHits
sort -r -k3,3 $OUTPUT/all.pubHits > all.pubhits

fi;
