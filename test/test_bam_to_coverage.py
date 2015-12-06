import nose.tools as nose
import tempfile
from scripts import bam_to_coverage

def test_process_idxstats():
    _, path = tempfile.mkstemp()
    with open(path, "r+") as idxstats_file:
        idxstats_file.write("""contig-1\t80\t1\t0
*\t0\t0\t0""")
        idxstats_file.seek(0)
        updated_map = bam_to_coverage.process_idxstats({}, idxstats_file)
        nose.assert_dict_equal(updated_map, {"contig-1":[80,1,0]})

def test_process_depth():
    _, path = tempfile.mkstemp()
    with open(path, "r+") as depth_file:
        depth_file.write("""contig-1\t1\t1
contig-1\t1\t1""")
        depth_file.seek(0)
        updated_map = bam_to_coverage.process_depth({"contig-1":[80,1,0]}, depth_file)
        nose.assert_dict_equal(updated_map, {"contig-1":[80,1,2]})

def test_check_bam():
    _, path = tempfile.mkstemp()
    try:
        bam_to_coverage.check(path)
    except SystemExit as se:
        nose.assert_equal(se.message, "Please index your bam file.")

def test_write_coverage():
    from StringIO import StringIO
    contig_map = {"contig-1":[80,1,2],
               "contig-2":[80,1,3]}
    out = StringIO()
    bam_to_coverage.write_coverage(contig_map,out=out)
    output = out.getvalue().strip()
    expected_out = "#ContigName\tContigLength\tMappedReads\tAvgCoverage\ncontig-2\t80\t1\t0.0375\ncontig-1\t80\t1\t0.025"
    nose.assert_equal(expected_out, output)