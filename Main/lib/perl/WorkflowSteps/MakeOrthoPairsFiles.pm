package ApiCommonWorkflow::Main::WorkflowSteps::MakeOrthoPairsFiles;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;


sub run {
  my ($self, $test, $undo) = @_;

  my $suffix = $self->getParamValue('suffix');
  my $confFile = $self->getParamValue('configFile');
  my $orthmclGroupsDir = $self->getParamValue('outputGroupsDir');

  my $workflowDataDir = $self->getWorkflowDataDir();
  my $configFile = "$workflowDataDir/$confFile";
  my $outDir = "$workflowDataDir/$orthmclGroupsDir";

  if ($undo) {
    $self->runCmd(0, "rm -rf $outDir");
  } else {
    $self->testInputFile('configFile', "$configFile");
    $self->runCmd(0, "mkdir $outDir");

      if ($test) {
	  $self->runCmd(0, "echo test > $outDir/mclInput");
      }
      $self->runCmd($test, "orthomclDumpPairsFiles $configFile $outDir $suffix");
  }
}


1;
