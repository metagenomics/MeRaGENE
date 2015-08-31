import os

__author__ = 'pbelmann'

import nose.tools as nose
import tempfile
from scripts import create_overview

OVERVIEW_HEADER = [
    'cov1\tcov2\tGene ID\tHMM\tClass\tscore HMM\tEvalue HMM\tBest blastp hit\tEvalue best blastp\tIdentity\tSubject accsession\tSubject titles\tSubject tax ids\tSubject ids\tLinks\tGene sequence\n']


def test_determine_class():
    clazz = create_overview.determine_class("(Bla)CARB")
    nose.assert_equal(clazz, "A")


def test_write_header():
    coverages = ["cov1", "cov2"]
    _, path = tempfile.mkstemp()
    with open(path, "r+") as temp_file:
        create_overview.writeHeader(coverages, temp_file)
        temp_file.seek(0)
        nose.assert_equals(temp_file.readlines(), OVERVIEW_HEADER)
    os.remove(path)
