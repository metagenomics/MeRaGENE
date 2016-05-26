#!/bin/bash 

#To get uniqe contigs, write sh uniqer.sh 1 <input> <output>
NUM=$1 # Number of contigs/genes in output. 1 means everything is unique.
INPUT=$2
OUTPUT=$3

PATTERN=""
I=0
ADD=1

touch $OUTPUT

# if arguments to ensure a correct execution
if [ $# -le 2 ]
  then
    echo "Wrong number of arguments."
    echo "To get uniqe contigs, write sh uniqer.sh 1 <input> <output>"

  elif [ -z "$1" ]
  then
    echo "Input amount missing"
  elif [ -z "$2" ]
  then
    echo "Input path missing"
  elif [ -z "$3" ]
  then 
    echo "Output path missing"
  else

# awk part to reduce every multiple space to a single space delimiter
awk 'BEGIN{OFS=" "}{for(i=1;i<NF;i++) printf "%s%s",$i,OFS; printf "%s\n", $NF}' $INPUT > $INPUT.space
# sort the output, so that the next while loop uses the lines in high to low order
awk '$10==1' $INPUT.space  | sort -r -g -k4f,4 -k14,14 > $INPUT.sortspace

# get the x best hits of every contig 
while read line; do 
	
  	ZEILE=$(cut -d" " -f4 <<< $line)

	if [ "$ZEILE" != "$PATTERN" ]
		then
		PATTERN=$ZEILE
		I=1
		
		echo $line >> $INPUT.best
	
	elif [ "$ZEILE" == "$PATTERN" ]
		then
		
		if [ $I -lt $NUM ]
			then
			echo $line >> $INPUT.best
		fi;
		((I = $I + $ADD))
	fi;


done < $INPUT.sortspace

  if [[ -s $INPUT.best ]] ; then
    #sort the ouptut data according to contig names
    sort -r -g -k1f,1 -k14,14 $INPUT.best > $OUTPUT
  fi
fi;
