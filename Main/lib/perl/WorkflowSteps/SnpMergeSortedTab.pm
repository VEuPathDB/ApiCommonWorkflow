package ApiCommonWorkflow::Main::WorkflowSteps::SnpMergeSortedTab;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);
use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test, $undo) = @_;

  my $inputFile = $self->getParamValue('inputFile');
  my $newSampleFile = $self->getParamValue('newSampleFile');
  my $snpStrain = $self->getParamValue('snpStrain');

  my $workflowDataDir = $self->getWorkflowDataDir();

  my $cmd = "mergeSortedSnpTab.pl --inputFile $workflowDataDir/$inputFile --cacheFile $workflowDataDir/$newSampleFile";

  if ($undo) {
    $cmd .= " --removeStrain $snpStrain";
    $self->runCmd(0, $cmd);
  } else {
      if ($test) {
	  $self->testInputFile('inputFile', "$workflowDataDir/$inputFile");
	  $self->runCmd(0, "echo test > $workflowDataDir/$newSampleFile");
      }else{
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
