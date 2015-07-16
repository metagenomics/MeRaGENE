#!/bin/sh 

# output of the hmm search which is the input for the best Hit search
INPUT=$1


# path for pearl skript
GREP_IDS_TO_FILES_BIN="/vol/pathomg/Skripte/grep_ids_to_files.pl"
# path for shell commands
BLASTP_BIN="/vol/cmg/bin/blastp"

# necessary sequences/databases
NCBI_DB="/vol/biodb/asn1/nr"
SEQUENCES="/vol/pathomg/DB/Plant1234DNA12_k31_gt1kb_genes.faa"
CREATEFOLDER="/vol/pathomg/Skripte/createFolder.sh"
#numner of threads
THREADS=4

if [[ ${PWD} == */ ]]
	then
	PWD=${PWD%?}
fi;

# creats all necessary folders for the qsub call
sh $CREATEFOLDER $PWD
MUSTER=""
I=0
ADD=1
JOB=0

# Error if illegal number of arguments
if [ $# != 1 ]
	then
	echo "The appeal for pipeline_blast.sh should be used like this:\nsh pipeline_blast.sh <Input>\nThe input should be the unique hmm search output\nDifferent outputs are generated: the blastp search output in txt format and html format and fasta files for every gene are generated."

else
	cut -d" " -f4 $INPUT > $INPUT.ids
	$GREP_IDS_TO_FILES_BIN $INPUT.ids $SEQUENCES
	while read line; do 
		
		ZEILE=$(cut -d" " -f4 <<< $line)
		#$AGREP_BIN -d '\>' $ZEILE $SEQUENCES > "$ZEILE.faa"
		
		# creats the *.txt output
		echo $BLASTP_BIN -db $NCBI_DB -outfmt \"6 qseqid sseqid pident length mismatch gapopen qstart qend sstart send evalue bitscore sallacc salltitles staxids sallseqid\" -query "$ZEILE.faa" -out "$ZEILE.txt" -num_threads $THREADS >> ./blastcalls.txt
		# creats the *.html output
		echo $BLASTP_BIN -db $NCBI_DB -query "$ZEILE.faa" -html -out "$ZEILE.html" -num_threads $THREADS >> ./blastcalls.txt
		((JOBS = $JOBS + 2))
		
		
		#qsub -l arch=lx24-amd64 -e ./error/ -o ./shellproms/ -pe multislot 8 -l vf=1G -cwd -N $ZEILE -b y $BLASTP_BIN -db $NCBI_DB -outfmt "6 qseqid sseqid pident length mismatch gapopen qstart qend sstart send evalue bitscore sallacc salltitles staxids sallseqid" -query "$ZEILE.faa" -out "$ZEILE.txt" -num_threads 8 
		# blastp with html output for more than a general overview
		#qsub -e ./error/ -o ./shellproms/ -pe multislot 8 -l vf=1G -cwd -N $ZEILE -b y $BLASTP_BIN -db $NCBI_DB -query "$ZEILE.faa" -html -out "$ZEILE.html" -num_threads 8 
			
		
	done < $INPUT
fi;

# submits invocations
qsub -l arch=lx24-amd64 -l vf=2G -t 1-$JOBS -pe multislot $THREADS -N "Blast_Jobs" -b y -e $PWD/error/ -o $PWD/out/ -cwd /vol/pathomg/Skripte/run_jobs.py ./blastcalls.txt

