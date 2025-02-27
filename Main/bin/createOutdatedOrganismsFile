#!/usr/bin/perl

use strict;
use warnings;
use Getopt::Long;

my ($new,$old,$outputFile);

&GetOptions("old=s"=> \$old,
	    "new=s"=> \$new,
	    "outputFile=s"=> \$outputFile);

open(my $o, '<', $old) || die "Could not open file $old: $!";
open(my $n, '<', $new) || die "Could not open file $new: $!";

my %oldAbbrevTomd5;
while (my $line = <$o>) {
    chomp $line;
    if ($line =~ /(\S+)\s*(\S+)/) {
        my $md5 = $1;
        my $abbrev = $2;
	$oldAbbrevTomd5{$abbrev} = $md5;
    }
    else {
	die "Improper file format for file $o. Line is $line\n";
    }
}
close $o;

my %newAbbrevTomd5;
while (my $line = <$n>) {
    chomp $line;
    if ($line =~ /(\S+)\s*(\S+)/) {
        my $md5 = $1;
        my $abbrev = $2;
	$newAbbrevTomd5{$abbrev} = $md5;
    }
    else {
	die "Improper file format for file $n. Line is $line\n";
    }
}
close $n;

open(OUT, '>', $outputFile) || die "Could not open file $outputFile: $!";

foreach my $abbrev (keys %oldAbbrevTomd5) {
    if (!$newAbbrevTomd5{$abbrev} || $newAbbrevTomd5{$abbrev} ne $oldAbbrevTomd5{$abbrev}) {
        print OUT "$abbrev\n";        
    }
}	
close OUT;
