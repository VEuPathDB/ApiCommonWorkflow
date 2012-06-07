package ApiCommonWorkflow::Main::WorkflowSteps::MakeOrthoPairsFiles;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;


sub run {
  my ($self, $test, $undo) = @_;

  my $suffix = $self->getParamValue('suffix');
  my $orthmclGroupsDir = $self->getParamValue('outputGroupsDir');

  my $workflowDataDir = $self->getWorkflowDataDir();
  my $configFile = "$workflowDataDir/orthomclPairs.config";
  my $outDir = "$workflowDataDir/$orthmclGroupsDir";
  $self->runCmd(0, "mkdir $outDir");

  if ($undo) {
    $self->runCmd($test, "rm -rf $outDir/pairs");
    $self->runCmd($test, "rm -rf $outDir/mclInput");
  } else {
      $self->testInputFile('configFile', "$configFile");

      if ($test) {
	  $self->runCmd(0, "echo test > $outDir/mclInput");
      }
      $self->runCmd($test, "orthomclDumpPairsFiles $configFile $outDir $suffix");
  }
}
