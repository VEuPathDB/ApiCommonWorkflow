package ApiCommonWorkflow::Main::WorkflowSteps::CopyDnaseqBigwigToWebSvc;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);
use strict;
use warnings;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;
use ApiCommonWorkflow::Main::Util::OrganismInfo;

sub run {
    my ($self, $test, $undo) = @_;

    my $copyFromDir = $self->getParamValue('copyFromDir');
    my $organismAbbrev = $self->getParamValue('organismAbbrev');
    my $relativeDir = $self->getParamValue('relativeDir');
    my $experimentDatasetName = $self->getParamValue('experimentDatasetName');
    my $gusConfigFile = $self->getParamValue('gusConfigFile');

    my $workflowDataDir = $self->getWorkflowDataDir();
    $gusConfigFile = "$workflowDataDir/$gusConfigFile";
    my $websiteFilesDir = $self->getWebsiteFilesDir($test);

    my $organismNameForFiles =
        $self->getOrganismInfo($test, $organismAbbrev, $gusConfigFile)->getNameForFiles();

    my $experimentCopyToDir = "$websiteFilesDir/$relativeDir/$organismNameForFiles/dnaseq/bigwig/$experimentDatasetName";
    my $sourceDir = "$workflowDataDir/$copyFromDir";

    $self->testInputFile('copyFromDir', $sourceDir);

    if ($undo) {
        $self->runCmd(0, "rm -rf $experimentCopyToDir");
    } else {
        $self->runCmd($test, "mkdir -p $experimentCopyToDir");

        opendir(my $dh, $sourceDir) or die "Cannot open results directory '$sourceDir': $!";
        my @samples = grep { !/^\./ && -d "$sourceDir/$_" } readdir($dh);
        closedir($dh);

        die "No sample subdirectories found in '$sourceDir'" unless @samples;

        foreach my $sample (@samples) {
            my $sampleCopyToDir = "$experimentCopyToDir/$sample";
            $self->runCmd($test, "mkdir -p $sampleCopyToDir");
            $self->runCmd($test, "cp $sourceDir/$sample/*.bw $sampleCopyToDir/");
        }
    }
}

1;
