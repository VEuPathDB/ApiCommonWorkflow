package ApiCommonWorkflow::Main::WorkflowSteps::MakeOrthoPairsFiles;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;


sub run {
  my ($self, $test, $undo) = @_;

  my $suffix = $self->getParamValue('suffix');
  my $orthmclGroupsDir = $self->getParamValue('outputGroupsDir');
  my $confFile = "$workflowDataDir/$confFile";

  my $workflowDataDir = $self->getWorkflowDataDir();
  my $configFile = "$workflowDataDir/$confFile";
  my $outDir = "$workflowDataDir/$orthmclGroupsDir";

  if ($undo) {
    $self->runCmd($test, "rm -rf $outDir");
  } else {
      $self->runCmd(0, "mkdir $outDir");
      $self->testInputFile('configFile', "$configFile");

      if ($test) {
	  $self->runCmd(0, "echo test > $outDir/mclInput");
      }
      $self->runCmd($test, "orthomclDumpPairsFiles $configFile $outDir $suffix");
  }
}
