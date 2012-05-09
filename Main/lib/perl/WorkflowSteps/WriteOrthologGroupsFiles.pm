package ApiCommonWorkflow::Main::WorkflowSteps::WriteOrthologGroupsFiles;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;


sub run {
  my ($self, $test, $undo) = @_;

  my $orthomclIdPrefix = $self->getParamValue('orthomclIdPrefix');
  my $inputFile = $self->getParamValue('inputFile');
  my $outputFile = $self->getParamValue('outputFile');
  my $startingOrthologGroupNumber = $self->getParamValue('startingOrthologGroupNumber');
  my $includeSingletons = $self->getParamValue('includeSingletons');
  my $proteinFile = $self->getParamValue('proteinFile');

  my $workflowDataDir = $self->getWorkflowDataDir();

  my $cmd = "orthomclMclToGroups $orthomclIdPrefix $startingOrthologGroupNumber < $workflowDataDir/$inputFile > $workflowDataDir/$outputFile";
  my $singletonCmd = "orthomclSingletons $proteinFile $orthomclIdPrefix >> $workflowDataDir/$outputFile";

  if ($undo) {
    $self->runCmd(0, "rm -f $workflowDataDir/$outputFile");
  } else {
      if ($test) {
	  $self->testInputFile('inputFile', "$workflowDataDir/$inputFile");
	  $self->runCmd(0,"echo test > $workflowDataDir/$outputFile");
      }

      $self->runCmd($test, $cmd);

      if ($includeSingletons) {
	$self->runCmd($test, $singletonCmd);
      }
    }
}

