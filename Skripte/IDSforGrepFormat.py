#!/usr/bin/python
from sys import argv

# removes all unnecessary characters form a file

if len(argv) != 3:
	print "Use Program like this: IDSforGrepFormat.py <Input> <Output>"

else:

	filename = argv[1]
	out = argv[2]

	file = open(filename,"r")
	output = open(out,"w")


	for line in file:
		line = line.replace("\t","")
		line = line.replace(">","")
		line = line.replace("\n","")
		line = line.replace("\r","")
		output.write(line+"\n")

	file.close()