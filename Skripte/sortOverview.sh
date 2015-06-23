#!/bin/sh 

#first argument: column number after which the overview should be sorted
#second argument: Inputfile (overview) which should be sorted
#third argument: Outputfile of the sorted document

COLUMN=$1
INPUT=$2
OUTPUT=$3


if [ $# != 3 ]
	then
	echo -e "The appeal for sortOverview.sh should be used like this:\nsh sortOverview.sh <Column> <Input> <Output>\nThe input should be the overview form creatOverview.py\nThe output is an overview which is sorted after the column you give in the program call."

else
	#first part divides the head from the remainding part so that only the filled rows are sorted
	(head -n 1 $INPUT && tail -n +2 $INPUT | sort -s -g -r -k$COLUMN,$COLUMN)  > $OUTPUT

fi;