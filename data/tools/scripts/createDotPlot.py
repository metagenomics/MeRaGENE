import matplotlib as mpl
# .use('svg') for hard-coded backend when running per ssh without display variable
# If .show() is used, this has to be commented 
mpl.use('svg')
import matplotlib.pyplot as plt; plt.rcdefaults()
import numpy as np
import os
import sys

pathToFile = sys.argv[1]
pathToResult = sys.argv[2]

# List for all x/y entries 
x = []
y = []
titel_x = "Coverage of the antibiotic resistance gene (%)"
titel_y = "Identity (%)"

with open(pathToFile,'r') as f:
    for line in f:
        # Split the tab separated lines to get single entries
        line_buffer = line.rstrip().split('\t')
        # Filter every entry wich is too small
        if float(line_buffer[15])*100 >= float(0.1) and float(line_buffer[2]) >= float(0.1):
            x.append(float(line_buffer[15])*100)
            y.append(float(line_buffer[2]))

plt.ylabel(titel_y)
plt.xlabel(titel_x)
plt.title(os.path.basename(pathToFile))
plt.axis([0, float(max(x))+2, 0, float(max(y))+2])
plt.plot( x, y, 'o', markersize=3, markerfacecolor='r', markeredgecolor='k',markeredgewidth=0.2)
# If .use('svg') is used, this does not function!!! 
#plt.show()
plt.savefig( pathToResult + "/" + os.path.basename(pathToFile) + ".png", dpi=600)
#plt.savefig("test.svg")
