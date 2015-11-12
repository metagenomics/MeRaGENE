#!/bin/sh 
# Script to search for specific keywords in pubmed abstracts provieded by ncbi link inputs.
# The .acc input file should contain links like this http://www.ncbi.nlm.nih.gov/protein/WP_012738633
# Hits are saved in .pubhit files.

INPUT=$1
OUTPUT=$2
KEYWORDS=$3

# if arguments to ensure a correct execution
if [ $# -le 1 ]
  then
    echo "Wrong number of arguments."
    echo "To execute write: sh UrltoPubmedID.sh <input file> <output path>"

  elif [ -z "$1" ]
  then
    echo "Input file missing"
  elif [ -z "$2" ]
  then
    echo "Output path missing"
  else

echo "Get HTML"

#Cut path to get name
NAME=${INPUT%.*}
NAME=${NAME##*/}

#ensure the right output format
if [[ ${OUTPUT} == */ ]]
	then
	OUTPUT=${OUTPUT%?}
fi;
echo $INPUT
while read line; do 
	
	#get accession html
 	accession=${line##*/}
	#download html
	curl "$line" > $OUTPUT/$accession.html
	#search for gi number
	uidString=$(grep "ncbi_uidlist" $OUTPUT/$accession.html)
	pos=$(echo $uidString | awk '{print index($uidString,"ncbi_uidlist")}')
	gi=$(echo $uidString | awk -v pos=$pos '{print substr($uidString, pos, 36)}')
	gi=$(cut -d'"' -f3 <<< $gi)
	
	#download asn with gi number
	curl "http://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=protein&id=$gi" > $OUTPUT/$accession.asn
	#search for pubmed id
	pubmedID=$(grep "pubmed" $OUTPUT/$accession.asn | awk '/[1-9]+/' | cut -d"d" -f2 | cut -d" " -f2)

	LEN=$(expr length "$pubmedID")
	#if pubmed is greater zero | exists
	if [ $LEN != "0" ] 
		then
		#download pubmed abstract
		curl "http://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=pubmed&id=$pubmedID&retmode=text&rettype=abstract" > $OUTPUT/$accession.pubmed
		#search for keywords
		pubtxt=$(grep -e "metallo" -e "carbapenemase" -e "bacteria" -e "zeffalospurin" -e "antibiotic" -e "resistance" -e "lactamase" -e "plasmid" -e "esbl" $OUTPUT/$accession.pubmed)
		
		LENGTH=$(expr length "$pubtxt")
		
		if [ $LENGTH != "0" ] 
			then
			echo -e "$NAME \t $accession \t http://www.ncbi.nlm.nih.gov/pubmed/$pubmedID" >> $OUTPUT/$accession.pubhit
			
			#the same procedure as above, to get multiple pubmed abstracts for the same gene
			while read pub; do
			
				if [ "$(grep "co" <<< $pub)" == "" ] 
				then
					curl "http://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=pubmed&id=$pub&retmode=text&rettype=abstract" > $OUTPUT/$accession.pubmed
					
                                        pubtxt=$(grep -F -f $KEYWORDS  $OUTPUT/$accession.pubmed)
		
					LENGTH=$(expr length "$pubtxt")
					
					if [ $LENGTH != "0" ] 
					then
						echo -e "$NAME \t $accession \t http://www.ncbi.nlm.nih.gov/pubmed/$pub" >> $OUTPUT/$accession.save
			
					fi;
				else
										
					echo "$pub" >> $OUTPUT/$accession.save
				fi;
		
			done < $OUTPUT/$accession.pubhit
			mv $OUTPUT/$accession.save $OUTPUT/$accession.pubhit
		fi;

	fi;
	
done < $INPUT

#move acc files to clean up directory
mv $INPUT $OUTPUT/acc_files

echo "finished"

fi;
