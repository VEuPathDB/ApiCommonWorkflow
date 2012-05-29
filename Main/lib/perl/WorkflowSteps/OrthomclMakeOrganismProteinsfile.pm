package ApiCommonWorkflow::Main::WorkflowSteps::OrthomclMakeOrganismProteinsFile;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

# add prefix to IDs in input file

sub run {
  my ($self, $test, $undo) = @_;

  my $inputProteinsFile = $self->getParamValue('inputProteinsFile');
  my $outputProteinsFile = $self->getParamValue('outputProteinsFile');
  my $proteinIdPrefix = $self->getParamValue('proteinIdPrefix');

  my $workflowDataDir = $self->getWorkflowDataDir();
  
  $self->testInputFile('inputProteinsFile', "$workflowDataDir/$inputProteinsFile");

  my $cmd = "orthomclAddIdPrefix $proteinIdPrefix $workflowDataDir/$inputProteinsFile $workflowDataDir/$outputProteinsFile";

  if ($undo) {
      $self->runCmd(0, "rm -f $workflowDataDir/$outputProteinsFile");
  }else {
      if ($test){
	  $self->runCmd(0, "echo test> $workflowDataDir/$outputProteinsFile");
      }
      $self->runCmd($test, $cmd);
  }
}

