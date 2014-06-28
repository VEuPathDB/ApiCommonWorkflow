package ApiCommonWorkflow::Main::WorkflowSteps::WriteOrthologGroupsFiles;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;


sub run {
  my ($self, $test, $undo) = @_;

  my $workflowDataDir = $self->getWorkflowDataDir();

  my $orthomclIdPrefix = $self->getParamValue('orthomclIdPrefix');
  my $inputFile = "$workflowDataDir/" . $self->getParamValue('inputFile');
  my $outputFile = "$workflowDataDir/" . $self->getParamValue('outputFile');
  my $startingOrthologGroupNumber = $self->getParamValue('startingOrthologGroupNumber');
  my $includeSingletons = $self->getParamValue('includeSingletons');
  my $proteinFile = "$workflowDataDir/" . $self->getParamValue('proteinFile');

  my $cmd = "orthomclMclToGroups $orthomclIdPrefix $startingOrthologGroupNumber < $inputFile > $outputFile";
  my $singletonCmd = "orthomclSingletons $proteinFile $outputFile $orthomclIdPrefix >> $outputFile";

  if ($undo) {
    $self->runCmd(0, "rm -f $outputFile");
  } else {
      if ($test) {
	  $self->runCmd(0,"echo test > $outputFile");
      }

      $self->testInputFile('inputFile', "$inputFile");
      $self->runCmd($test, $cmd);

      if ($includeSingletons) {
	$self->runCmd($test, $singletonCmd);
      }
    }
}

