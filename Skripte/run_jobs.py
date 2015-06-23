#! /usr/bin/env python2.7
# This program is called during the blastp analysis, it is not necessary to call it on your own.
import os
import sys
import subprocess

jobfile = open(sys.argv[1])

task_id = int(os.environ["SGE_TASK_ID"])

lines = jobfile.readlines()

jobfile.close()

subprocess.call(lines[task_id-1].strip(), shell=True)