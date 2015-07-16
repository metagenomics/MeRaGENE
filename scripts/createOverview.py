#!/usr/bin/env python

# This script creates the first version of an overview
# It is called from the Overview.sh skript

# If you don't want to run this skript with qsub your call should look like this: 
# python createOverview.py HMM-Hits.unique
# Furthermore this program needs the fasta files and the blastp.txt files,
# therefore you need to be sure these files are in the same directory as the unique HMM-Hits file.
# The output is an overview.txt file in the same directory.
# In this overview file the pubmed analysis is not done in this stage,
# so a continuing programm will overwork it.

from sys import argv
import os
import shutil

# variables for infomation which will be presented in the overview file
# biogas plat coverage will be read out of this files
BIOGASPLANT1 = "/vol/pathomg/DB/Plant1DNA1_gt1kb_bt2.bam.coverage.txt"
COV_BIOGASPLANT1 = 0
BIOGASPLANT2= "/vol/pathomg/DB/Plant2DNA1_gt1kb_bt2.bam.coverage.txt"
COV_BIOGASPLANT2 = 0
BIOGASPLANT3 = "/vol/pathomg/DB/Plant3DNA1_gt1kb_bt2.bam.coverage.txt"
COV_BIOGASPLANT3 = 0
BIOGASPLANT4 = "/vol/pathomg/DB/Plant4DNA1_gt1kb_bt2.bam.coverage.txt"
COV_BIOGASPLANT4 = 0
# contig ID in the coverage files
contig = ""

# Infos from the unique HMMHits file
ID = ""
HMM = ""
SCORE = ""
CLASS = ""
# Infos from the ID.txt files
BLASTP = ""
EVALUE = ""
IDENTITY = ""
SUBACCES = ""
SUBTIT = ""
SUBTAXID = ""
SUBID = ""
# Info from the ID.faa files
SEQ = ""

# wont be filled out in this overview (placeholder)
LINK = "TODO"

# path of the unique HMMHits file, to create the files and folders in the same direction
pathway = ""



# head of the overview file
head = "cov biogas plant1" + "\t" + "cov biogas plant2" + "\t" + "cov biogas plant3" + "\t" + "cov biogas plant4" + "\t" + "Gene ID" + "\t" + "HMM" + "\t" + "Class" + "\t" + "score HMM" + "\t" + "Evalue HMM" + "\t" + "Best blastp hit" + "\t" + "Evalue best blastp" + "\t" + "Identity" + "\t" + "Subject accsession" + "\t" + "Subject titles" + "\t" + "Subject tax ids" + "\t" + "Subject ids" + "\t" + "Links" + "\t" +"Gene sequence" + "\n"

# Error if illegal number of arguments
if len(argv) != 2:
	print "Use Program like this: createOverview.py <Input> \nThe input should be the file with the best hits of blastp\nIn the same direction as the best Hits, there will be created an overview file and two folders. This two foldes will comprise the txt/faa files and the html files."
	
# What to do for correct number of arguments
else:
	filename = argv[1]
	file_Hits = open(filename)
	
	# to create the outputfile in the same directory as the input file, the path of the HMMHits file is analysed
	datei = ""
	pathfinder = filename.split("/")
	if (len(pathfinder) == 1):
		print"if"
		file = open("overview.txt", "a")
		
	else:
		while p < (len(pathfinder)-1):
			if p == 0:
				print "path if"
				pathway = pathfinder[p] + "/"
				p = p + 1
			else:
				print "path else"
				pathway = pathway + pathfinder[p] + "/"
				p = p + 1
		datei = pathway+"overview.txt"
		file = open(datei , "a")
	file.write(head)	
	
	# all this infomation will be presented in the overview file
	line = file_Hits.readlines()
	for i in line:
		# will be filled with all informations for one contig
		row = ""
		liste = i.split()
		# get all possible information out of the input file, most important is the ID
		ID = liste[3]
		HMM = liste[0]
		SCORE = liste[7]
		EVALHMM = liste [6]
		
		#biogas plant coverage
		#biogas plant1
		BIOGASPLANT1_file = open(BIOGASPLANT1).readlines()
		for bp1 in BIOGASPLANT1_file:
			bp1_liste = bp1.split("\t")
			contig = bp1_liste[0]+"_"	
			if (ID.startswith(contig)):
				COV_BIOGASPLANT1 = bp1_liste[3] 
				COV_BIOGASPLANT1 = COV_BIOGASPLANT1[:-1]
		del BIOGASPLANT1_file
		
		#biogas plant2
		BIOGASPLANT2_file = open(BIOGASPLANT2).readlines()
		for bp2 in BIOGASPLANT2_file:
			bp2_liste = bp2.split("\t")
			contig = bp2_liste[0]+"_"	
			if (ID.startswith(contig)):
				COV_BIOGASPLANT2 = bp2_liste[3] 
				COV_BIOGASPLANT2 = COV_BIOGASPLANT2[:-1]
		del BIOGASPLANT2_file
				
		#biogas plant3
		BIOGASPLANT3_file = open(BIOGASPLANT3).readlines()
		for bp3 in BIOGASPLANT3_file:
			bp3_liste = bp3.split("\t")
			contig = bp3_liste[0]+"_"	
			if (ID.startswith(contig)):
				COV_BIOGASPLANT3 = bp3_liste[3] 
				COV_BIOGASPLANT3 = COV_BIOGASPLANT3[:-1]
		del BIOGASPLANT3_file
		
		#biogas plant4
		BIOGASPLANT4_file = open(BIOGASPLANT4).readlines()
		for bp4 in BIOGASPLANT4_file:
			bp4_liste = bp4.split("\t")
			contig = bp4_liste[0]+"_"	
			if (ID.startswith(contig)):
				COV_BIOGASPLANT4 = bp4_liste[3] 
				COV_BIOGASPLANT4 = COV_BIOGASPLANT4[:-1]
		del BIOGASPLANT4_file
		
		# classification (this needs to be changed if no betalactamases should be analysed anymore)
		if (HMM == "(Bla)CARB") or (HMM == "(Bla)CEPA") or (HMM == "(Bla)cfxA") or (HMM == "(Bla)CTX") or (HMM == "(Bla)FONA") or (HMM == "(Bla)GES")or (HMM == "(Bla)HERA") or (HMM == "(Bla)KPC") or (HMM == "(Bla)LEN") or (HMM == "(Bla)OKP") or (HMM == "(Bla)OXY") or (HMM == "(Bla)PER") or (HMM == "(Bla)SHV") or (HMM == "(Bla)TEM") or (HMM == "(Bla)VEB"):
			CLASS = "A"
		elif (HMM == "(Bla)B") or (HMM == "(Bla)cfiA") or (HMM == "(Bla)cphA") or (HMM == "(Bla)GOB") or (HMM == "(Bla)IMP") or (HMM == "(Bla)VIM") or (HMM == "(Bla)NDM") or (HMM == "(Bla)IND"):
			CLASS = "B"
		elif (HMM == "(Bla)ACT") or (HMM == "(Bla)CMY") or (HMM == "(Bla)DHA") or (HMM == "(Bla)FOX") or (HMM == "(Bla)MIR") or (HMM == "(Bla)OCH"):
			CLASS = "C"
		elif (HMM == "(Bla)OXA") or (HMM == "(Bla)OXA_2"):
			CLASS = "D"
		else:
			CLASS = "N/A"
		
		
		# open contig-*.txt files, to get further informations
		file_bp = pathway + ID + ".txt"
		if os.path.isfile(file_bp):	
			line_blastp = open(file_bp).readlines()
			if len(line_blastp) > 0:
				liste_blastp = line_blastp[0].split('\t')	
				BLASTP = liste_blastp[1]
				EVALUE = liste_blastp[10]
				IDENTITY = liste_blastp[2]
				SUBACCES = liste_blastp[12]
				SUBTIT = liste_blastp[13]
				SUBTAXID = liste_blastp[14]
				SUBID = liste_blastp[15]
				SUBID = SUBID[:-1]	
		else:
			BLASTP = "N/A"
			EVALUE = "N/A"
			IDENTITY = "N/A"	
			SUBACCES = "N/A"
			SUBTIT = "N/A"
			SUBTAXID = "N/A"
			SUBID = "N/A"
		del line_blastp
  
		# open contig-*.faa files, to get the sequences of the contigs
		file_seq = pathway + ID + ".faa"
		if os.path.isfile(file_seq):
			line_seq = open(file_seq).readlines()

			if len(line_seq) > 0:
				SEQ = ""
				j=1
				for i in line_seq:
					if j > 1:
						SEQ = (SEQ.rstrip()) + i
						SEQ = SEQ[:-1]
					j = j + 1
				if SEQ.endswith("*"):
					SEQ = SEQ 
				else:
                    # the sequence seems to be incomplete, the last character is cutted of because it ends with a line break
					SEQ = SEQ[:-1]		
		else:
			SEQ = "N/A"
		j=1
		del line_seq
		
		## print the inforation for one gene in one row 
		row = COV_BIOGASPLANT1 + "\t" + COV_BIOGASPLANT2 + "\t" + COV_BIOGASPLANT3 + "\t" + COV_BIOGASPLANT4 + "\t" + ID + "\t" + HMM + "\t" + CLASS + "\t" + SCORE + "\t" + EVALHMM + "\t" + BLASTP + "\t" + EVALUE + "\t"   +IDENTITY + "\t"+ SUBACCES + "\t"+ SUBTIT + "\t" + SUBTAXID + "\t"+ SUBID + "\t"+ LINK + "\t"+SEQ  + "\n"
		file.write(row)
		
		# when the overview is created, the .txt and .faa files are not necessary anymore.  
		# they will be moved in another folder called "txt_faa_files"		
		datafolder = pathway + "txt_faa_files"
		# create folders and move files
		if not os.path.exists(datafolder):
			os.mkdir(datafolder)
			shutil.move(file_seq, datafolder)
			shutil.move(file_bp, datafolder)	
		else:
			shutil.move(file_seq, datafolder)
			shutil.move(file_bp, datafolder)
			
		# all .html files will be moved in another folder as well,
        # this .html files has been generated by the blastp-program
        # They were not necessary for the overview, but they can be useful for interesting hits
		htmlfolder = pathway + "HTML_files"
        	htmlsource = ""
		htmlsource = pathway + ID + ".html"
		if not os.path.exists(htmlfolder):
			os.mkdir(htmlfolder)
			if os.path.isfile(htmlsource):
				shutil.move(htmlsource, htmlfolder)
		else:
			if os.path.isfile(htmlsource):
				shutil.move(htmlsource, htmlfolder)
	
file.close()
