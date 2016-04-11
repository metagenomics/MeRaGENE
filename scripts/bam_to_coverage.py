#!/usr/bin/python
"""
Usage: bam_to_coverage.py [options] <file.bam>

-h --help     Please enter an indexed bam file

"""

import os
import sys
import distutils
from docopt import docopt
from sys import argv
import subprocess
from functools import partial

def run_command(command, func):
	p = subprocess.Popen(command, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
	out = p.stdout
	return func(out)

def process_idxstats(contig_map, out):
	"""
	:param contig_map: map to set contigs cov data
	:param out: samtools idxstats output file
	:return: contigs map
	"""
	for line in out:
		if line.startswith('*'): continue
		name, length, reads, _ = line.rstrip().split('\t')
		contig_map[name] = [int(length), int(reads), 0]
	return contig_map

def process_depth(contig_map, out):
	"""
    :param contig_map: map with contig ids as keys
    :param out: samtools depth output
	:return: contig_map with ids in it
	"""
	for line in out:
		name, _, num_contigs = line.rstrip().split('\t')
		contig_map[name][2] += int(num_contigs)
	return contig_map

def write_coverage(contig_map, out=sys.stdout):
	out.write("#ContigName\tContigLength\tMappedReads\tAvgCoverage\n")
	for key in contig_map:
		contig_map[key][2] /= float(contig_map[key][0])  #depthcounter /contig_length
		out.write(key + '\t' + '\t'.join(str(elem) for elem in contig_map[key]) + '\n')

def run_depth_wrapper(bam_file, partial_process_depth, contig):
	return run_command(["samtools", "depth", "-r", contig, bam_file], partial_process_depth)

def check(bam):
	if not os.path.isfile(bam + ".bai"):
		sys.exit('Please index your bam file.')
	if not distutils.spawn.find_executable("samtools"):
		sys.exit('Please install samtools and add it to your PATH')

def main():
	args = docopt(__doc__, argv[1:])
	bam_file = args['<file.bam>']
	check(bam_file)

	partial_process_idxstats = partial(process_idxstats, {})
	contigs_map = run_command(["samtools", "idxstats", bam_file], partial_process_idxstats)

	partial_process_depth = partial(process_depth, contigs_map)
	cov = run_command(["samtools", "depth", bam_file], partial_process_depth)

	write_coverage(cov)

if __name__ == '__main__':
	main()
