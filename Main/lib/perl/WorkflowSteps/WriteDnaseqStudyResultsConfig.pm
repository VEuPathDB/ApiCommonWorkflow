package ApiCommonWorkflow::Main::WorkflowSteps::WriteDnaseqStudyResultsConfig;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);
use strict;
use warnings;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;
use ApiCommonWorkflow::Main::Util::DnaseqSamplesheet;

my @COLUMNS = ('Name', 'File Name', 'Source Id Type', 'Input ProtocolAppNodes', 'Protocol', 'ProtocolParams', 'ProfileSet');

sub run {
    my ($self, $test, $undo) = @_;

    my $resultsDirectory = $self->getParamValue('resultsDirectory');
    my $sampleSheetFile = $self->getParamValue('sampleSheetFile');
    my $experimentDatasetName = $self->getParamValue('experimentDatasetName');
    my $configOutputFile = $self->getParamValue('configOutputFile');

    my $workflowDataDir = $self->getWorkflowDataDir();
    my $sourceDir = "$workflowDataDir/$resultsDirectory";
    my $sampleSheetPath = "$workflowDataDir/$sampleSheetFile";
    my $outputPath = "$workflowDataDir/$configOutputFile";

    if ($undo) {
        $self->runCmd(0, "rm -f $outputPath");
        return;
    }

    if ($test) {
        $self->runCmd(0, "echo test > $outputPath");
        return;
    }

    my @samples = ApiCommonWorkflow::Main::Util::DnaseqSamplesheet::getSampleNames($sampleSheetPath);

    open(my $out, '>', $outputPath) or die "Cannot open config file '$outputPath' for writing: $!";

    print $out join("\t", @COLUMNS) . "\n";

    foreach my $sample (@samples) {
        $self->writeRow($out, $sourceDir, $sample, $experimentDatasetName,
                         'Ploidy', "${sample}_Ploidy.txt", 'NASequence', 'Ploidy');

        $self->writeRow($out, $sourceDir, $sample, $experimentDatasetName,
                         'GeneCNV', "${sample}_geneCNVs.txt", 'gene', 'geneCNV');

        $self->writeRow($out, $sourceDir, $sample, $experimentDatasetName,
                         'Indel', "${sample}_indelsForLoad.tsv", 'NASequence', 'Indel');
    }

    close $out;
}

sub writeRow {
    my ($self, $out, $sourceDir, $sample, $experimentDatasetName, $label, $fileBasename, $sourceIdType, $protocol) = @_;

    my $file = "$sample/$fileBasename";

    die "No $label file found for sample '$sample' at '$sourceDir/$file'" unless -e "$sourceDir/$file";

    my $name = "${sample}_$label";
    my $profileSet = "$experimentDatasetName - $label";

    print $out join("\t", $name, $file, $sourceIdType, '', $protocol, '', $profileSet) . "\n";
}

1;
