#!/usr/bin/env python

"""
usage: getFasta.py --i <contigLine> --g <genomeFaa> --b <home>
"""
from sys import argv
from docopt import docopt
from Bio import SeqIO
from Bio.SeqRecord import SeqRecord
from Bio.Seq import Seq
import re
import os
import time


def main():
    args = docopt(__doc__, argv[1:])
    contigL = args['<contigLine>']
    gen = args['<genomeFaa>']
    home = args['<home>']
    
    start = contigL.split(' ')[17]
    stop = contigL.split(' ')[18]
    contig = contigL.split(' ')[3]
    
    if not os.path.exists(home+"/txt_faa_files/"):
    	os.makedirs(home+"/txt_faa_files/")

    for record in SeqIO.parse(gen, "fasta") :
    	line = re.findall(contig, record.id)
    	if line:
		SeqIO.write(SeqRecord(Seq(str(record.seq[int(int(start)-1):int(stop)])),id=record.id,description=record.description),home+"/txt_faa_files/"+record.id+".faa","fasta")
        	SeqIO.write(SeqRecord(Seq(str(record.seq[int(int(start)-1):int(stop)])),id=record.id,description=record.description),'uniq_out',"fasta")
        	SeqIO.write(SeqRecord(Seq(str(record.seq[int(int(start)-1):int(stop)])),id=record.id,description=record.description),'cut_faa',"fasta")
		time.sleep(2)
		
		if not os.path.isfile(home+"/txt_faa_files/"+record.id+".faa"):
			SeqIO.write(SeqRecord(Seq(str(record.seq[int(int(start)-1):int(stop)])),id=record.id,description=record.description),home+"/"+record.id+".faa","fasta")
        		SeqIO.write(SeqRecord(Seq(str(record.seq[int(int(start)-1):int(stop)])),id=record.id,description=record.description),'uniq_out',"fasta")
        		SeqIO.write(SeqRecord(Seq(str(record.seq[int(int(start)-1):int(stop)])),id=record.id,description=record.description),'cut_faa',"fasta")
			time.sleep(6)
	
    
if __name__ == '__main__':
    main()
    
