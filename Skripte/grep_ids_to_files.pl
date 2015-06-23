#!/usr/bin/env perl

sub Usage {
    die <<"EOT";
\nUsage: $0 IDFILE FASTAFILE

    $0 prints all entries given by IDFILE which are found in FASTAFILE to single files

EOT
}

&Usage if ($#ARGV < 1);

$idfile = $ARGV[0];
$fastafile = $ARGV[1];
$pair_read = 'read';

open(IDS,$idfile) || die "cannot open IDFILE: $!";
while(<IDS>) {
    chomp;
    $ids{"$_"} = 1;
}
close IDS;


my $entry;

open INFILE,$fastafile or die "Can't open: $fastafile";
$description=<INFILE>;
while ($in = <INFILE>) {
    unless ($in =~ /^>\S+/) {
	$entry .= $in;
    }
    else {
	if ($description =~ /^>(\S+)/) {
	    $id=$1;
	}
	else {
	    $id='';
	}


	if (exists $ids{$id}) {
	    print STDERR "writing file $id.faa...\n";
	    open(OUT,">$id.faa") || die "cannot open file; $!";
	    print OUT $description.$entry;
	    close OUT;
	}

	$description=$in;
	$entry="";
    }
}

close INFILE;

# check last entry

if ($description =~ /^>(\S+)/) {
    $id=$1;
}
else {
    $id='';
}

if (exists $ids{$id}) {
	    open(OUT,">$id.faa") || die "cannot open file; $!";
	    print OUT $description.$entry;
	    close OUT;
}
