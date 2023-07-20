package ApiCommonWorkflow::Main::WorkflowSteps::MakeBlatNextflowConfig;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use warnings;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
    my ($self, $test, $undo) = @_;

    my $clusterWorkflowDataDir = $self->getClusterWorkflowDataDir();
    my $workflowDataDir = $self->getWorkflowDataDir();
    my $outputDir = join("/", $clusterWorkflowDataDir, $self->getParamValue("outputDir")); 
    my $configFileName = $self->getParamValue("configFileName");
    my $configPath = join("/", $workflowDataDir,  $self->getParamValue("analysisDir"), $self->getParamValue("configFileName"));
    my $seqFile = join("/", $clusterWorkflowDataDir, $self->getParamValue("queryFile"));
    my $fastaSubsetSize = $self->getParamValue("fastaSubsetSize");
    my $databasePath = join("/", $clusterWorkflowDataDir, $self->getParamValue("databasePath"));
    my $maxIntronSize = $self->getParamValue("maxIntronSize");
    my $dbType = $self->getParamValue("dbType");
    my $queryType = $self->getParamValue("queryType");
    my $blatParams = $self->getParamValue("blatParams");
    my $trans = $self->getParamValue("trans");
  
    if ($undo) {
	$self->runCmd(0,"rm -rf $configPath");
    } else {
	open(F, ">", $configPath) or die "$! :Can't open config file '$configPath' for writing";

    print F
"
params {
  seqFile = \"$seqFile\"
  fastaSubsetSize = $fastaSubsetSize
  databasePath = \"$databasePath\"
  maxIntron = $maxIntronSize
  dbType = \"$dbType\"
  queryType = \"$queryType\"
  blatParams = \"$blatParams\"
  trans = $trans
  outputDir = \"$$outputDir\"
}
process {
  container = 'veupathdb/blat:latest'
}
singularity {
  enabled = true
  autoMounts = true
}
";
	close(F);
    }
}

1;
