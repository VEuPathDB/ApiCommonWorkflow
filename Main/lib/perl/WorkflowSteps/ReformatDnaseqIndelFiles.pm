package ApiCommonWorkflow::Main::WorkflowSteps::ReformatDnaseqIndelFiles;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);
use strict;
use warnings;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;
use ApiCommonWorkflow::Main::Util::DnaseqSamplesheet;

sub run {
    my ($self, $test, $undo) = @_;

    my $resultsDirectory = $self->getParamValue('resultsDirectory');
    my $sampleSheetFile = $self->getParamValue('sampleSheetFile');

    my $workflowDataDir = $self->getWorkflowDataDir();
    my $sourceDir = "$workflowDataDir/$resultsDirectory";
    my $sampleSheetPath = "$workflowDataDir/$sampleSheetFile";

    my @samples = ApiCommonWorkflow::Main::Util::DnaseqSamplesheet::getSampleNames($sampleSheetPath);

    foreach my $sample (@samples) {
        my $indelFile = "$sourceDir/$sample/${sample}_indels.tsv";
        my $reformattedFile = "$sourceDir/$sample/${sample}_indelsForLoad.tsv";

        if ($undo) {
            $self->runCmd(0, "rm -f $reformattedFile");
            next;
        }

        if ($test) {
            $self->runCmd(0, "echo test > $reformattedFile");
            next;
        }

        die "No indel file found for sample '$sample' at '$indelFile'" unless -e $indelFile;

        open(my $in, '<', $indelFile) or die "Cannot open indel file '$indelFile': $!";
        open(my $out, '>', $reformattedFile) or die "Cannot open reformatted indel file '$reformattedFile': $!";

        print $out "na_sequence_id\tlocation\tshift\n";

        while (my $line = <$in>) {
            chomp $line;
            next unless length($line);

            my ($sampleName, $seqId, $location, $shift) = split(/\t/, $line);

            print $out "$seqId\t$location\t$shift\n";
        }

        close $in;
        close $out;
    }
}

1;
