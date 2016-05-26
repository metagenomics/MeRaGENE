#!/usr/bin/env python

"""
usage: UrlToPubmed.py --in <input> --out <output> --keyw <keywords>
"""
from sys import argv
from docopt import docopt
from Bio import SeqIO
import urllib3
import re
from Bio import Entrez
import os.path

def main():
    args = docopt(__doc__, argv[1:])
    input = args['<input>']
    output = args['<output>']
    keywords = args['<keywords>']
    
    accFile = open(input, "r")
    accession = accFile.readline()
    fileName = os.path.splitext(os.path.basename(input))[0] #File name ohne Endung, fuer spaeteren gebrauch
    accessionName = accession.split('/',4)[4].rstrip('\n')
    
    http = urllib3.PoolManager()
    r = http.request('GET', accession.rstrip('\n')) # Erste (und eigentlich einziege) URL aus Acc File einlesen und moegliche Zeilenumbrueche entfernen http://www.ncbi.nlm.nih.gov/protein/CDL66413/CDL61215
    gi = re.findall(r'<meta name="ncbi_uidlist" content="(\d*)', r.data) #gibt eine !Liste! an treffern aus. 
    handle = Entrez.efetch(db="protein", id=gi[0], rettype="gp", retmode="xml")
    record = Entrez.read(handle)
    handle.close()
    
    if re.findall("GBReference_pubmed",str(record[0])): # Type conversion, da findall nur Strings und Buffer durchsuchen kann 
	    pubmedID = record[0]["GBSeq_references"][0]["GBReference_pubmed"] #obwohl angeblich vom Typ dicionary, traversierbar wie eine Mischung aus Array/Dictionary. Betrachtbar mit JsonViewer 
	    handle = Entrez.efetch(db="pubmed", id=pubmedID, rettype="abstract", retmode="text")
	    record = handle.read() #Nicht EntrezViewer, da Output plain Text
	    handle.close()
	    keySearchResult = int(0)
	    with open(keywords, "r") as wordDocument:
	    	for word in wordDocument:
			if re.findall(word.rstrip('\n'),record):
				keySearchResult = int(1)
				break
    
		f = open(os.path.abspath(output) + "/" + fileName +'.pubhit', 'w')
		f.write(fileName + "\t" + accessionName + "\t" + "http://www.ncbi.nlm.nih.gov/pubmed/" + pubmedID + "\n")


if __name__ == '__main__':
    main()
