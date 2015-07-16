#!/bin/sh

#$ -S /bin/sh
#$ -N CreateFolder
#
#Standard program to check if all necessary folders exist. If not they are created.
#
# sh createFolder.sh "INPUTFOLDER"

IN=$1
# if arguments to ensure a correct execution
if [ $# -ne 1 ]
  then
    echo "Wrong number of arguments."
    echo "Execute like this: sh createFolder.sh <INPUTFOLDER>"
  else

#Cut all paths to the same format, no / at the end.
if [[ ${IN} == */ ]]
	then
	IN=${IN%?}
fi;

#Check if folder exists, if not create.
if [ ! -d "$IN/error" ]; then
	mkdir $IN/error
fi

if [ ! -d "$IN/out" ]; then
	mkdir $IN/out
fi

#While folder is not invocable, create error message.
while [ ! -d "$IN/error" ]
do
	sleep 5
	echo "Still creating folder error ..."
done
#change rights to ensure that other users can call other parts of the pipeline in the future.
chmod 770 $IN/error

while [ ! -d "$IN/out" ]
do
	sleep 5
	echo "Still creating folder out ..."
done
chmod 770 $IN/out

fi;