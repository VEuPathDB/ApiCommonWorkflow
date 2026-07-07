package ApiCommonWorkflow::Main::Util::DnaseqSamplesheet;

use strict;
use warnings;

# The samplesheet may contain more than one row per sample (e.g. multiple SRA
# ids mapped to the same sample), so we dedupe on the first column.
sub getSampleNames {
    my ($sampleSheetPath) = @_;

    open(my $fh, '<', $sampleSheetPath) or die "Cannot open samplesheet '$sampleSheetPath': $!";

    my (@samples, %seen);
    while (my $line = <$fh>) {
        chomp $line;
        next if $line =~ /^\s*#/;
        next if $line =~ /^\s*$/;
        next if $line =~ /^sample/i;

        my ($sample) = split(/,/, $line);

        next if $seen{$sample}++;
        push @samples, $sample;
    }

    close $fh;

    return @samples;
}

1;
