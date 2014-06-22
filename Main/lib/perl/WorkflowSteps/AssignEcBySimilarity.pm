package ApiCommonWorkflow::Main::WorkflowSteps::AssignEcBySimilarity;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);
use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test, $undo) = @_;

  my $inputBlastFile = $self->getParamValue('inputBlastFile');
  my $inputEcFile = $self->getParamValue('inputEcFile');
  my $outputMappingFile = $self->getParamValue('outputMappingFile');

  my $workflowDataDir = $self->getWorkflowDataDir();

  if ($undo) {
    $self->runCmd(0, "rm $workflowDataDir/$outputMappingFile") if -e "$workflowDataDir/$outputMappingFile";
  } else {
    $self->testInputFile('inputBlastFile', "$workflowDataDir/$inputBlastFile");
    $self->testInputFile('inputEcFile', "$workflowDataDir/$inputEcFile");

    my $cmd = "matchOrthomclEcNumbers -blastFile $workflowDataDir/$inputBlastFile -inputEcMappingFile $workflowDataDir/$inputEcFile -outputEcMappingFile $workflowDataDir/$outputMappingFile";
    $self->runCmd($test, $cmd);
    if ($test) {
      $self->runCmd(0, "touch $workflowDataDir/$outputMappingFile");
    }

  }
}

