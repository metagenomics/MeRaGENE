#!/usr/bin/python
# This program revises the existing overview file.
# If a keyword is found in an Abstract of an accession of a gene, the url of the abstract is added to the overview file
"""
Usage: link_assignment.py -o <overview> -pub <pubhits>

-h --help     Please enter the files overview.txt and the pubhits.

"""
from docopt import docopt
from sys import argv
import csv
import os
import util


def load_pubhits_in_dict(pubhits_path):
    with open(pubhits_path, 'r') as pubhits_file:
        pubhits_reader = csv.reader(pubhits_file, delimiter='\t', )
        return dict((row[util.PUBHITS_GENE_ID_INDEX].strip(), row) for row in pubhits_reader)


def build_overview_link(pubhits_dict, gene_id, links):
    """
    builds the pubhits link out of the gene id and the pubhits dict
    :param pubhits_dict: pubhits dictionary
    :param gene_id: gene id
    :param links: existsing links
    :return: links
    """
    pubhits_acc = pubhits_dict[gene_id][util.PUBHITS_ACC_INDEX]
    pubhits_link = pubhits_dict[gene_id][util.PUBHITS_LINK_INDEX]
    overview_link = ','.join([links, pubhits_acc + ":" + pubhits_link])
    if not overview_link or overview_link == util.TODO:
        overview_link = util.NO_KEYWORDS
    return overview_link


def set_link_in_row(old_row, pubhits_dict):
    """
    set link in existing overview row (dictionary)
    :param old_row: overview row
    :param pubhits_dict: pubhits dictionary
    :return: revised overview row
    """
    gene_id = old_row[util.GENE_ID]
    if (gene_id in pubhits_dict):
        old_row[util.LINKS] = build_overview_link(pubhits_dict, gene_id, old_row[util.LINKS])
    return old_row


def main():
    args = docopt(__doc__, argv[1:])
    overview_path = args['<overview>']
    pubhits = args['<pubhits>']
    new_overview_path = os.path.splitext(overview_path)[0] + "_new.txt"
    pubhits_dict = load_pubhits_in_dict(pubhits)
    with open(overview_path, 'r') as overview, open(new_overview_path, 'w') as new_overview:
        overview_reader = csv.DictReader(overview, delimiter='\t')
        overview_writer = csv.DictWriter(new_overview, delimiter='\t', extrasaction='ignore',
                                         fieldnames=overview.readline().rstrip('\n').split("\t"))
        overview.seek(0)
        overview_writer.writeheader()
        for overview_row in overview_reader:
            overview_row = set_link_in_row(overview_row, pubhits_dict)
            overview_writer.writerow(overview_row)


if __name__ == '__main__':
    main()
