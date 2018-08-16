import matplotlib as mpl
# .use('Agg') for hard-coded backend when running per ssh without display variable 
mpl.use('Agg')
import matplotlib.pyplot as plt; plt.rcdefaults()
import numpy as np
import os 
import sys

# Import path 
pathToDir = sys.argv[1]
dirList = os.listdir(pathToDir)
dataArray = []
# If values not given, use default
filter_1 = sys.argv[2] if len(sys.argv) >= 3 else 1.0
filter_1_place = 15
filter_2 = sys.argv[3] if len(sys.argv) >= 4 else 98
filter_2_place = 2
titel_x = "Test Titel x"
titel_y = "Anzahl:"

for dir in dirList:
    if dir.endswith(".cov"):
        if not pathToDir.endswith("/"):
            pathToDir = pathToDir+"/"
        with open(pathToDir + dir, 'r') as f:
            
            buffer = []
            counter = 0
            buffer.append(dir)
            
            for line in f:
                
                line_buffer = line.rstrip().split('\t')
                
                if float(line_buffer[filter_1_place]) >= float(filter_1) and float(line_buffer[filter_2_place]) >= float(filter_2):
                    counter += 1

            buffer.append(counter)

            dataArray.append(buffer)

# data to plot
groups = len(dataArray)

# create plot
objects = ()
performance = []
titel_x = ''.join(dataArray[0][0].split('.')[0].split('_')[0:2])

for box in dataArray:
    objects = objects + (box[0].split('.')[0].split('_')[2],)
    print(box[0].split('.')[0].split('_')[2]+"\t"+str(box[1]))
    performance.append(box[1])

y_pos = np.arange(len(objects))
 
plt.bar(y_pos, performance, align='center', alpha=0.5)
plt.xticks(y_pos, objects, rotation='vertical')
plt.ylabel(titel_y)
plt.title(titel_x)

# Tweak spacing to prevent clipping of tick-labels
plt.subplots_adjust(bottom=0.25)
plt.suptitle("Param: "+str(filter_1_place)+" >= "+str(filter_1)+" - "+str(filter_2_place)+" >= "+str(filter_2))

plt.plot()
plt.savefig(pathToDir+titel_x+"_"+str( filter_1_place )+"_"+str(filter_1)+"_"+str( filter_2_place )+"_"+str( filter_2 )+".png", dpi=600)
#plt.show()
