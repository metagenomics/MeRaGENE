#!/usr/bin/env python

"""
Usage: link_search.py -o <overview.txt> -out <output_folder>

-h --help     Please enter an overview.txt file and an output folder.

"""
import functools
from docopt import docopt
from sys import argv
import util
import csv
import os

NCBI_PROTEIN_URL = "http://www.ncbi.nlm.nih.gov/protein/"
ACC_FILE_EXTENSION = ".acc"


def get_subject_accs(subject_accessions):
    """
    Returns list of rul created from an string ACC1;ACC2;...
    :param subject_accessions: "ACC1;ACC2,.."
    :return: list of urls
    """
    return map(lambda acc: NCBI_PROTEIN_URL + acc, subject_accessions.split(";"))


def write_link_to_file(link, path_to_dir, gene_id):
    with open(os.path.join(path_to_dir, gene_id + ACC_FILE_EXTENSION), 'w') as acc:
        acc.write(link+'\n')


def main():
    args = docopt(__doc__, argv[1:])
    overview_path = args['<overview.txt>']
    output_folder = args['<output_folder>']
    with open(overview_path, 'r') as overview:
        reader = csv.DictReader(overview, delimiter='\t')
        for row in reader:
            gene_id = row['Gene ID']
            subject_acc = row[util.SUBJECT_ACCESSION]
            if subject_acc != util.NOT_AVAILABLE:
                links = get_subject_accs(subject_acc)
                map(functools.partial(write_link_to_file, path_to_dir=output_folder, gene_id=gene_id), links)


if __name__ == '__main__':
    main()
