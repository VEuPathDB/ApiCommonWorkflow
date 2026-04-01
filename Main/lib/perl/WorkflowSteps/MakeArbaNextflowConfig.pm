package ApiCommonWorkflow::Main::WorkflowSteps::MakeArbaNextflowConfig;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use warnings;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
    my ($self, $test, $undo) = @_;
    my $workflowDataDir = $self->getWorkflowDataDir();
    my $clusterWorkflowDataDir = $self->getClusterWorkflowDataDir();
    my $configFileName = $self->getParamValue("configFileName");
    my $configPath = join("/", $workflowDataDir,  $self->getParamValue("analysisDir"), $self->getParamValue("configFileName"));
    my $clusterServer = $self->getSharedConfig("clusterServer");
    my $arbaRulesheet = join("/", $self->getSharedConfig("$clusterServer.softwareDatabasesDirectory"),$self->getSharedConfig("arbaRulesheet"));

    my $interproResults = $self->getParamValue("interproResults");
    my $proteome = $self->getParamValue("proteome");    
    my $outputDir = $self->getParamValue("outputDir");
    my $workingDirRelativePath = $self->getParamValue("workingDirRelativePath");
    my $taxonId = $self->getParamValue("taxonId");
    my $abbrev = $self->getParamValue("abbrev");

    my $digestedInterproResults = $self->relativePathToNextflowClusterPath($workingDirRelativePath, $interproResults);
    my $digestedProteome = $self->relativePathToNextflowClusterPath($workingDirRelativePath, $proteome);    
    my $digestedOutputDir = $self->relativePathToNextflowClusterPath($workingDirRelativePath, $outputDir);

    my $executor = $self->getClusterExecutor();
    my $queue = $self->getClusterQueue();

    if ($undo) {
	$self->runCmd(0,"rm -rf $configPath");
    } else {
	open(F, ">", $configPath) or die "$! :Can't open config file '$configPath' for writing";

    print F
"
params {
  interproResults = \"$digestedInterproResults\"
  outputDir = \"$digestedOutputDir\"
  proteome = \"$digestedProteome\"
  taxonId = $taxonId
  abbrev = \"$abbrev\"
  ruleSheet = \"$arbaRulesheet\"
}

process{
  executor = \'$executor\'
  queue = \'$queue\'
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
