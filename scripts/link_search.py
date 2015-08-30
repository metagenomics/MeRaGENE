#!/usr/bin/python
# This file creates several *.acc files which contain the NCBI protein links for one specific gene.
# The input file should be the first generated overview, the *.acc files will be generated in the same directory as the overview-file.
from sys import argv
import os
#gene of interest
GENE = ""
# entry of subaccession in the overview (several subaccessions seperated by ";")
SUBACC = ""
# list of all subaccessions for one gene 
SUBACC_liste = ""
# specific subaccessions
ACC = ""
# some genes have no blasthit, this should be displayed
NOBLAST = ""
# fixed NCBI url (just the beginning of every url)
PREURL = "http://www.ncbi.nlm.nih.gov/protein/"
# will be set on the url for each gene with all possible subaccessions
NCBI = ""
# the first line of the overview is a head, there is no gene id represented
j = 1
# used for the path finding of the input file
i = 0
# used for the different amount of subaccessions for one gene 
k=0
# path of the input file
path = ""

# Error if illegal number of arguments
if len(argv) != 2:
	print "The appeal for the protein-url search should look like this:\nlinksuche.py <Input>\nThe input file should be the overview file. As output, there will be several 'geneID'.acc files which contain all URLs for this specific gene with all their accessions.\nThis 'geneID'.acc files will be at the same direction as the input file."

else:
	filename = argv[1]
	file_overview = open(filename)
	
	#find path for the outputfiles
	pathfinder = filename.split("/")
	if (len(pathfinder) == 1):	
		path = "./"
	else:	
		while i < (len(pathfinder)-1):
			if i == 0:
				path = pathfinder[i] + "/"
				i = i + 1
			else:
				path = path + pathfinder[i] + "/"
				i = i + 1
	
	# look for blast hits and create the *.acc files
	line = file_overview.readlines()
	j=1
	for i in line:
		liste = i.split("\t")
		NCBI = ""
		# get the gene ID
		if j>1:
			GENE=liste[4]
			datei = path + GENE + ".acc"
			file = open(datei , "a")
			# if one gene has no blast hit, there should be no .acc file for this gene	
			if liste[12] == "N/A":
				NOBLAST = " has no blastp hit"
				print GENE + NOBLAST
				os.remove(datei)
			# complete the *.acc file	
			else:
				SUBACC = liste[12]
				SUBACC_liste = SUBACC.split(";")
				while k < len(SUBACC_liste):
					ACC = SUBACC_liste[k]
					NCBI = PREURL + ACC + "\n"
					file.write(NCBI)
					k = k+1
			file.close()
			k=0
		j= j+1
		del SUBACC_liste
		SUBACC = ""
		ACC = ""
	file_overview.close()


