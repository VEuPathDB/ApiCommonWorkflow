package ApiCommonWorkflow::Main::WorkflowSteps::MakeLongReadRnaSeqNextflowConfig;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use warnings;
use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
    my ($self, $test, $undo) = @_;

    my $chunkSize = 10000;
    
    my $resultsDirectory = $self->getParamValue("resultsDirectory");
    my $sampleSheet = $self->getParamValue("sampleSheetFile");
    my $genomeFile = $self->getParamValue("genomeFile");
    my $gtfFile = $self->getParamValue("gtfFile");
    my $inputDir = $self->getParamValue("inputDir");

    my $nextflowConfigFile = $self->getParamValue("nextflowConfigFile");

    my $organismAbbrev = $self->getParamValue("organismAbbrev");
    my $platform = $self->getParamValue("platform");
    my $build = $self->getParamValue("databaseBuild");

    my $maxFracA = $self->getParamValue("maxFracA");
    my $minCount = $self->getParamValue("minCount");
    my $minDatasets = $self->getParamValue("minDatasets");

    my $workflowDataDir = $self->getWorkflowDataDir();

    my $workingDirRelativePath = $self->getParamValue("workingDirRelativePath");

    my $digestedInputDirPath = $self->relativePathToNextflowClusterPath($workingDirRelativePath, $inputDir);

    my $digestedGenomeFilePath = $self->relativePathToNextflowClusterPath($workingDirRelativePath, $genomeFile);
    my $digestedGtfFilePath = $self->relativePathToNextflowClusterPath($workingDirRelativePath, $gtfFile);

    my $digestedOutputDir = $self->relativePathToNextflowClusterPath($workingDirRelativePath, $resultsDirectory);

    my $clusterServer = $self->getSharedConfig('clusterServer');
    my $clusterWorkflowDataDir = $self->getClusterWorkflowDataDir();
    my $executor = $self->getClusterExecutor();

    my $clusterConfigFile = "\$baseDir/conf/${executor}.config";


    if ($undo) {
        $self->runCmd(0,"rm -rf $configPath");
    } else {
        open(F, ">", $configPath) or die "$! :Can't open config file '$configPath' for writing";
        print F
            " 
params {
    input = "$digestedInputDirPath"
    samplesheetFileName = "$samplesheet"
    gtf = "$digestedGtfFilePath"
    fasta = "$digestdGenomeFilePath"
    splitChunk = $chunkSize
    platform = "$platform"
    build = "$build"
    annotationName = "$organismAbbrev"
    results = "$digestedOutputDir"
    maxFracA = $maxFracA
    minCount = $minCount
    minDatasets = $minDatasets
}

includeConfig "$clusterConfigFile"

 ";

        close(F);

    }
}
1;
