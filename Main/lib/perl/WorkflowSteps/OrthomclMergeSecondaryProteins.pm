package ApiCommonWorkflow::Main::WorkflowSteps::OrthomclMergeSecondaryProteins;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;
use File::Basename;


sub run {
  my ($self, $test, $undo) = @_;

  my $inputRepGroupsFile = $self->getParamValue('inputRepGroupsFile');
  my $inputTierOneGroupsDir = $self->getParamValue('inputTierOneGroupsDir');
  my $outputMergedGroupsFile = $self->getParamValue('outputMergedGroupsFile');

  my $workflowDataDir = $self->getWorkflowDataDir();

  my $cmd = "orthomclMergeSecondaryProteins $workflowDataDir/$inputRepGroupsFile $workflowDataDir/$outputMergedGroupsFile $workflowDataDir/$inputTierOneGroupsDir";

  $self->testInputFile('inputRepGroupsFile', "$workflowDataDir/$inputRepGroupsFile");
  $self->testInputFile('inputTierOneGroupsDir', "$workflowDataDir/$inputTierOneGroupsDir");

  if ($undo) {
      $self->runCmd(0, "rm -f $workflowDataDir/$outputMergedGroupsFile");
  }else {
      if ($test){
	  $self->runCmd(0, "echo test> $workflowDataDir/$outputMergedGroupsFile");
      }else{
	  $self->runCmd($test, $cmd);
      }
  }

}



