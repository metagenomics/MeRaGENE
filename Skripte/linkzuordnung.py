#!/usr/bin/python
# This program overworks the existing overview file.
# If a keyword is found in an Abstract of an accession of a gene, the url of the abstract is added to the overview file
from sys import argv

# infos cut out of the already existing overview
BIOPLANT1 = ""
BIOPLANT2 = ""
BIOPLANT3 = ""
BIOPLANT4 = ""
gene_ID = ""
HMM = ""
CLASS = ""
SCORE = ""
EVALHMM = ""
BLASTP = ""
EVALUE = ""
IDENTITY = ""
SUBACCES = ""
SUBTIT = ""
SUBTAXID = ""
SUBID = ""
SEQ = ""
# infos of the pubmed hit
pubhits_gene_ID = ""
pubhits_ACC = ""
pubhits_LINK = ""
LINK = ""
LINK2=""
pubhits = []
row = ""
# path finding
path = ""
p = 0

if len(argv) != 3:
	print "Use Program like this: linkzuordnung.py <Overview file> <Pubhits file>"

else:
	overview = argv[1]
	file_overview = open(overview)
	pathfinder = overview.split("/")
	# create the new overview file in the same directory as the first one
	if (len(pathfinder) == 1):
		path = "./"
	else:
		while p < (len(pathfinder)-1):
			if p == 0:
				path = pathfinder[p] + "/"
				p = p + 1
			else:
				path = path + pathfinder[p] + "/"
				p = p + 1
	path_new_overview  = path + "overview_new.txt"
	file_out = open(path_new_overview, "a")
 
	pubhits = argv[2]
	file_pubhits = open(pubhits)
	line_overview = file_overview.readlines()
	line_pubhits = file_pubhits.readlines()
	
	for i in line_overview:
		liste_overview = i.split("\t")
        # first of all the head should be in the new overview		
		if liste_overview[0] == "cov biogas plant1":
			row = i
       # set several informations
		else:
			# set known information
			BIOPLANT1 = liste_overview[0]
			BIOPLANT2 = liste_overview[1]
			BIOPLANT3 = liste_overview[2]
			BIOPLANT4 = liste_overview[3]
			gene_ID = liste_overview[4]
			HMM = liste_overview[5]
			CLASS = liste_overview[6]
			SCORE = liste_overview[7]
			EVALHMM = liste_overview[8]
			BLASTP = liste_overview[9]
			EVALUE = liste_overview[10]
			IDENTITY = liste_overview[11]
			SUBACCES = liste_overview[12]
			SUBTIT = liste_overview[13]
			SUBTAXID = liste_overview[14]
			SUBID = liste_overview[15]
			SEQ = liste_overview[17]
			SEQ = SEQ[:-1]
			#check out for links
			for j in line_pubhits:
				liste_pubhits = j.split("\t")
				
				pubhits_gene_ID_space = liste_pubhits[0]
				pubhits_ACC = liste_pubhits[1]
				pubhits_LINK_enter = liste_pubhits[2]
				pubhits_LINK = pubhits_LINK_enter[:-1]
				pubhits_gene_ID = pubhits_gene_ID_space[:-1]
				if (gene_ID == pubhits_gene_ID):
					
					info_LINK = pubhits_ACC + ":" + pubhits_LINK
                     # add the first url to the field
					if (LINK == ""):
						LINK = info_LINK
                     # add another url to the url field
					else:
						LINK = LINK + "\t" + info_LINK 
			if (LINK == ""):
				LINK = "no keywords found"
			row = BIOPLANT1 + "\t" + BIOPLANT2 + "\t" + BIOPLANT3 + "\t" + BIOPLANT4 + "\t" + gene_ID + "\t" + HMM + "\t" + CLASS + "\t" + SCORE + "\t" + EVALHMM + "\t" + BLASTP + "\t" + EVALUE + "\t" + IDENTITY + "\t" + SUBACCES + "\t" + SUBTIT + "\t" + SUBTAXID + "\t" + SUBID  + "\t" + LINK  + "\t" + SEQ + "\n"
			
		file_out.write(row)
		LINK = ""
	file_out.close()
	file_overview.close()
	file_pubhits.close()
				
		