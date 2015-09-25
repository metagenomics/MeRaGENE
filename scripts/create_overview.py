#!/usr/bin/env python

"""
Usage: createOverview.py -u <HMM-Hits.unique> -faa <faa_folder> -o <output_folder> -c <coverage_files>...

-h --help     Please enter a HMM.unique file, faa folder, output folder and as many coverage files as you want to.

"""
from sys import argv
from docopt import docopt
import functools
import csv
from Bio import SeqIO
import os
import shutil
import util


def writeHeader(coverages, file):
    header = [util.GENE_ID,
              util.HMM, util.CLASS, util.SCORE_HMM,
              util.EVAL_HMM, util.BEST_BLASTP_HIT,
              util.EVALUE_BEST_BLASTP, util.IDENTITY,
              util.SUBJECT_ACCESSION, util.SUBJECT_TITLES,
              util.SUBJECT_TAXIDS, util.SUBJECT_IDS,
              util.LINKS, util.GENE_SEQUENCE]
    file.write(("\t".join(coverages + header)) + '\n')


def move_txt_faa_files(output, file_txt, file_faa):
    if os.path.exists(file_txt):
        shutil.move(file_txt, output)
    if os.path.exists(file_faa):
        shutil.move(file_faa, output)


def move_html_files(output, file_html):
    if os.path.exists(file_html):
        shutil.move(file_html, output)


def determine_class(hmm):
    """
    Returns class of the HMM protein.
    :param hmm: HMM
    :return: CLASS
    """
    if (hmm == "(Bla)CARB") or (hmm == "(Bla)CEPA") or (hmm == "(Bla)cfxA") or (hmm == "(Bla)CTX") or (
                hmm == "(Bla)FONA") or (hmm == "(Bla)GES") or (hmm == "(Bla)HERA") or (hmm == "(Bla)KPC") or (
                hmm == "(Bla)LEN") or (hmm == "(Bla)OKP") or (hmm == "(Bla)OXY") or (hmm == "(Bla)PER") or (
                hmm == "(Bla)SHV") or (hmm == "(Bla)TEM") or (hmm == "(Bla)VEB"):
        clazz = "A"
    elif (hmm == "(Bla)B") or (hmm == "(Bla)cfiA") or (hmm == "(Bla)cphA") or (hmm == "(Bla)GOB") or (
                hmm == "(Bla)IMP") or (hmm == "(Bla)VIM") or (hmm == "(Bla)NDM") or (hmm == "(Bla)IND"):
        clazz = "B"
    elif (hmm == "(Bla)ACT") or (hmm == "(Bla)CMY") or (hmm == "(Bla)DHA") or (hmm == "(Bla)FOX") or (
                hmm == "(Bla)MIR") or (hmm == "(Bla)OCH"):
        clazz = "C"
    elif (hmm == "(Bla)OXA") or (hmm == "(Bla)OXA_2"):
        clazz = "D"
    else:
        clazz = "N/A"
    return clazz


def get_contig_txt_information(contig):
    """
    Extracts contig information.
    :param contig: contig file
    :return: various information
    """
    BLASTP = util.NOT_AVAILABLE
    EVALUE = util.NOT_AVAILABLE
    IDENTITY = util.NOT_AVAILABLE
    SUBACCES = util.NOT_AVAILABLE
    SUBTIT = util.NOT_AVAILABLE
    SUBTAXID = util.NOT_AVAILABLE
    SUBID = util.NOT_AVAILABLE
    if os.path.isfile(contig):
        with open(contig, 'rb') as f:
            reader = csv.reader(f, delimiter='\t')
            for row in reader:
                BLASTP = row[1]
                EVALUE = row[10]
                IDENTITY = row[2]
                SUBACCES = row[12]
                SUBTIT = row[13]
                SUBTAXID = row[14]
                SUBID = row[15][:-1]
                break;
    return [BLASTP, EVALUE, IDENTITY, SUBACCES, SUBTIT, SUBTAXID, SUBID]


def get_coverage_information(coverage_path, id):
    """
    Extracts coverage information
    :param coverage_path:
    :param id: id of the contig
    :return: coverage value
    """
    with open(coverage_path, 'r') as coverage_file:
        cov = 0
        reader = csv.DictReader(coverage_file, delimiter='\t')
        for row in reader:
            contig = row[util.CONTIG_NAME] + "_"
            if (id.startswith(contig)):
                cov = row[util.AVG_COVERAGE]
        return cov


def get_sequence(contig_faa):
    """
    get sequence from a faa file with one entry
    :param contig_faa: faa sequence
    :return: faa sequence
    """
    seq = util.NOT_AVAILABLE
    if os.path.isfile(contig_faa):
        record = SeqIO.read(open(contig_faa), "fasta")
        seq = record.seq
    return seq

def main():
    args = docopt(__doc__, argv[1:])
    unique_file_path = args["<HMM-Hits.unique>"]
    faa_folder = args['<faa_folder>']
    output = args['<output_folder>']
    coverage_files = args['<coverage_files>']
    faa_txt_folder = os.path.join(output, util.FAA_TXT_OUTPUT_FOLDER)
    html_folder = os.path.join(output, util.HTML_OUTPUT_FOLDER)

    if not os.path.exists(faa_txt_folder):
        os.makedirs(faa_txt_folder)
    if not os.path.exists(output):
        os.makedirs(html_folder)

    with open(unique_file_path, 'r') as unique, open(os.path.join(output, util.OVERVIEW_TXT), 'w') as output_file:
        writeHeader(coverage_files, output_file)
        reader = unique.readlines()
        for line in reader:
            row = line.split()
            LINK = util.NO_LINK
            ID = row[3]
            HMM = row[0]
            SCORE = row[7]
            EVALHMM = row[6]
            txt_path = os.path.join(faa_folder, ID + ".txt")
            faa_path = os.path.join(faa_folder, ID + ".faa")

            coverages = map(functools.partial(get_coverage_information, id=ID), coverage_files)
            contigTxtInfo = get_contig_txt_information(txt_path)
	    if os.path.exists(faa_path):
	    	if not os.stat(faa_path).st_size == 0:
	    		SEQ = get_sequence(faa_path)
	    	else:
            		SEQ = "NO_SEQ"
            else:
            	SEQ = "NO_SEQ"	

            CLASS = determine_class(HMM)

            coverages.extend([ID, HMM, CLASS, SCORE, EVALHMM] + contigTxtInfo + [LINK, SEQ])
            output_file.write(('\t'.join(str(x) for x in coverages)) + '\n')

            move_html_files(html_folder, os.path.join(faa_txt_folder, ID + ".html"))
            move_txt_faa_files(faa_txt_folder, txt_path, faa_path)


if __name__ == '__main__':
    main()
