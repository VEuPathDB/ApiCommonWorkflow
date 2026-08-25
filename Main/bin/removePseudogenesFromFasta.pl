#!/usr/bin/perl

use strict;
use warnings;
use Getopt::Long;

=pod

=head1 Description

Remove pseudogene sequences from a protein fasta file. Every fasta entry
whose sequence ID matches an ID in the pseudogene list is dropped; all other
entries are written back out unchanged.

=head1 Input Parameters

=over 4

=item inputFasta

The fasta file to filter

=back

=over 4

=item pseudogenes

A file listing pseudogene sequence IDs, one per line

=back

=over 4

=item outputFasta

The filtered fasta file to write

=back

=cut

my ($inputFasta, $pseudogenes, $outputFasta);

&GetOptions("inputFasta=s" => \$inputFasta,
            "pseudogenes=s" => \$pseudogenes,
            "outputFasta=s" => \$outputFasta
           );

open(my $pseudoFh, '<', $pseudogenes) || die "Could not open file $pseudogenes: $!";
my %isPseudogene;
while (my $line = <$pseudoFh>) {
    chomp $line;
    next unless $line;
    $isPseudogene{$line} = 1;
}
close $pseudoFh;

open(my $in, '<', $inputFasta) || die "Could not open file $inputFasta: $!";
open(my $out, '>', $outputFasta) || die "Could not open file $outputFasta for writing: $!";

my $skipCurrentSeq = 0;
my ($totalRemoved, $totalKept) = (0, 0);

while (my $line = <$in>) {
    if ($line =~ /^>(\S+)/) {
        my $seqId = $1;
        if ($isPseudogene{$seqId}) {
            $skipCurrentSeq = 1;
            $totalRemoved++;
        }
        else {
            $skipCurrentSeq = 0;
            $totalKept++;
        }
    }

    print $out $line unless $skipCurrentSeq;
}

close $in;
close $out;

print STDERR "removePseudogenesFromFasta: removed $totalRemoved sequence(s), kept $totalKept sequence(s)\n";

1;
