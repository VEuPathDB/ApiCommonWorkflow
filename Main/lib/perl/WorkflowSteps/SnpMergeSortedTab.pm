package ApiCommonWorkflow::Main::WorkflowSteps::SnpMergeSortedTab;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);
use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test, $undo) = @_;

  my $inputFile = $self->getParamValue('inputFile');
  my $newSampleFile = $self->getParamValue('newSampleFile');
  my $undoneStrainsFile = $self->getParamValue('undoneStrainsFile');

  my $workflowDataDir = $self->getWorkflowDataDir();

  my $cmd = "mergeSortedSnpTab.pl --inputFile $workflowDataDir/$inputFile --cacheFile $workflowDataDir/$newSampleFile --undoneStrainsFile $workflowDataDir/$undoneStrainsFile";

  unless ($undo) {
    if($test) {
      $self->testInputFile('inputFile', "$workflowDataDir/$inputFile");
      $self->runCmd(0, "echo test > $workflowDataDir/$newSampleFile");
    } else{
      $self->runCmd($test, $cmd);
    }
  }
}

sub getConfigDeclaration {
  return (
         # [name, default, description]
         # ['', '', ''],
         );
}
