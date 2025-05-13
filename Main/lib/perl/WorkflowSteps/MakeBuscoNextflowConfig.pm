package ApiCommonWorkflow::Main::WorkflowSteps::MakeBuscoNextflowConfig;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use warnings;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
    my ($self, $test, $undo) = @_;

    my $maxForks = 2;

    my $clusterServer = $self->getSharedConfig("clusterServer");
    my $buscoLineagesDatabase = join("/", $self->getSharedConfig("$clusterServer.softwareDatabasesDirectory"), $self->getSharedConfig("buscoLineagesDirectory"));

    my $workflowDataDir = $self->getWorkflowDataDir();
    my $clusterWorkflowDataDir = $self->getClusterWorkflowDataDir();

    my $proteinSequenceFile = $self->getParamValue("proteinSequenceFile");
    my $genomicSequenceFile = $self->getParamValue("genomicSequenceFile");
    my $lineageMappersFile = $self->getParamValue("buscoLineageMappersFile");

    my $nextflowConfigFile = $self->getParamValue("nextflowConfigFile");
    my $resultsDirectory = $self->getParamValue("resultsDirectory");
    my $outputFilePrefix = $self->getParamValue("outputFilePrefix");
    my $workingDirRelativePath = $self->getParamValue("workingDirRelativePath");

    my $skipProteomeAnalysis = $self->getBooleanParmValue("isAnnotatedGenome") ? "false" : "true";

    my $speciesNcbiTaxonId = $self->getParamValue("speciesNcbiTaxonId");
    
    my $executor = $self->getClusterExecutor();
    my $clusterConfigFile = "\$baseDir/conf/${executor}.config";

    if ($undo) {
        $self->runCmd(0, "rm $workflowDataDir/$nextflowConfigFile");

    } else {
      my $nextflowConfig = "$workflowDataDir/$nextflowConfigFile";
      open(F, ">$nextflowConfig") || die "Can't open task prop file '$nextflowConfig' for writing";

      my $proteinSequenceFileInNextflowWorkingDirOnCluster = $self->relativePathToNextflowClusterPath($workingDirRelativePath, $proteinSequenceFile);
      my $genomeSequenceFileInNextflowWorkingDirOnCluster = $self->relativePathToNextflowClusterPath($workingDirRelativePath, $genomicSequenceFile);
      my $lineageMappersFileInNextflowWorkingDirOnCluster = $self->relativePathToNextflowClusterPath($workingDirRelativePath, $lineageMappersFile);

      my $resultsDirectoryInNextflowWorkingDirOnCluster = $self->relativePathToNextflowClusterPath($workingDirRelativePath, $resultsDirectory);


      my $configString = <<NEXTFLOW;
params {
  genomeFile = "$genomeSequenceFileInNextflowWorkingDirOnCluster"
  proteinFile = "$proteinSequenceFileInNextflowWorkingDirOnCluster"
  outDir = "$resultsDirectoryInNextflowWorkingDirOnCluster"
  ncbiTaxId = $speciesNcbiTaxonId
  buscoDownloadsDir = "$buscoLineagesDatabase"
  lineageMappingFile = "$lineageMappersFileInNextflowWorkingDirOnCluster"
  skipProteomeAnalysis = $skipProteomeAnalysis
}

process {
    maxForks = $maxForks
}


includeConfig "$clusterConfigFile"

NEXTFLOW
      print F $configString;
      close(F);
    }
}

1;
