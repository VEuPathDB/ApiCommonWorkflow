package ApiCommonWorkflow::Main::WorkflowSteps::OrthomclMakeGoodProteinsForSample;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;
use File::Basename;


sub run {
  my ($self, $test, $undo) = @_;

  my $proteomeFile = $self->getParamValue('proteomeFile');
  my $outputGoodProteinsFile = $self->getParamValue('outputGoodProteinsFile');
  my $outputBadProteinsFile = $self->getParamValue('outputBadProteinsFile');
  my $minLength = $self->getParamValue('minLength');
  my $maxStopPercent = $self->getParamValue('maxStopPercent');

  my $workflowDataDir = $self->getWorkflowDataDir();

  my $cmd = "orthomclFilterSingularFasta '$workflowDataDir/$proteomeFile' $minLength $maxStopPercent $workflowDataDir/$outputGoodProteinsFile $workflowDataDir/$outputBadProteinsFile";

  $self->testInputFile('proteomesDir', "$workflowDataDir/$proteomesDir");

  if ($undo) {
      $self->runCmd(0, "rm -f $workflowDataDir/$outputGoodProteinsFile");
      $self->runCmd(0, "rm -f $workflowDataDir/$outputBadProteinsFile");
  }else {
    if ($test){
      $self->runCmd(0, "echo test> $workflowDataDir/$outputGoodProteinsFile");
      $self->runCmd(0, "echo test> $workflowDataDir/$outputBadProteinsFile");
    }
    $self->runCmd($test, $cmd);
  }

}

1;
