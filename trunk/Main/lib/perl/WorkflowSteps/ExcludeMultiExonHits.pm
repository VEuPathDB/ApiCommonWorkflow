package ApiCommonWorkflow::Main::WorkflowSteps::ExcludeMultiExonHits;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;


sub run {
  my ($self, $test, $undo) = @_;

  my $inputUniqueFile = $self->getParamValue('inputUniqueFile');

  my $inputNonUniqueFile = $self->getParamValue('inputNonUniqueFile');

  my $workflowDataDir = $self->getWorkflowDataDir();

    if ($undo) {
    $self->runCmd(0, "rm -f $workflowDataDir/$inputUniqueFile");
    $self->runCmd(0, "rm -f $workflowDataDir/$inputNonUniqueFile");
    $self->runCmd(0, "mv $workflowDataDir/$inputUniqueFile.save $workflowDataDir/$inputUniqueFile");
    $self->runCmd(0, "mv $workflowDataDir/$inputNonUniqueFile.save $workflowDataDir/$inputNonUniqueFile");
  } else {
      if ($test) {
      }else{
	  $self->runCmd($test,"mv $workflowDataDir/$inputUniqueFile $workflowDataDir/$inputUniqueFile.save");
	  $self->runCmd($test,"mv $workflowDataDir/$inputNonUniqueFile $workflowDataDir/$inputNonUniqueFile.save");
	  $self->runCmd($test,"grep -v ',' $workflowDataDir/$inputUniqueFile.save > $workflowDataDir/$inputUniqueFile");
	  $self->runCmd($test,"grep -v ',' $workflowDataDir/$inputNonUniqueFile.save > $workflowDataDir/$inputNonUniqueFile");
      }
  }
}

sub getParamDeclaration {
  return (
	  'inputUniqueFile',
	  'inputNonUniqueFile',
	 );
}

sub getConfigDeclaration {
  return (
	  # [name, default, description]
	 );
}

