#!/usr/bin/env perl
#andreas@cebitec.uni-bielefeld.de

use strict;
use warnings;

my %hash = ();
my $bamfile = shift or die "\nUsage: $0 <sorted and indexed BAM file>\n\n";
die "ERROR: $bamfile does not exists.\n" unless (-e "$bamfile");
`samtools index $bamfile` unless (-e "$bamfile.bai");
die "ERROR: Could not index BAM file, is your BAM sorted already?\n" unless (-e "$bamfile.bai");

print "#ContigName\tContigLength\tMappedReads\tAvgCoverage\n";

open(my $samtools_idxstats, "-|", "samtools idxstats $bamfile") or die $!;
while (my $tmpline = <$samtools_idxstats>) {
	my @tmparray = split("\t", $tmpline);
	next if($tmparray[0] eq '*');
	push(@{$hash{$tmparray[0]}}, $tmparray[1]);   # contiglength
	push(@{$hash{$tmparray[0]}}, $tmparray[2]);   # mapped reads
	push(@{$hash{$tmparray[0]}}, 0);              # init depthcounter
}
close $samtools_idxstats;

open(my $samtools_depth, "-|", "samtools depth $bamfile") or die $!;
while (my $tmpline = <$samtools_depth>) {
	my @tmparray = split("\t", $tmpline);
	@{$hash{$tmparray[0]}}[2] += $tmparray[2];    # add depths per base
}
close $samtools_depth;

for my $contig ( sort keys %hash ) {
	@{$hash{$contig}}[2] /= @{$hash{$contig}}[0]; # depthcounter / contiglength = coverage
	print "$contig\t".join("\t", @{$hash{$contig}})."\n";
}
