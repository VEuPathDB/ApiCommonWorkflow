package ApiCommonWorkflow::Main::WorkflowSteps::LoadArrayElementFeature;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;


sub run {

  my ($self, $test, $undo) = @_;

  my $inputFile = $self->getParamValue('inputFile');

  my $extDbRlsSpec = $self->getParamValue('extDbRlsSpec');

  my $workflowDataDir = $self->getWorkflowDataDir();
  
  my $args = "--extDbSpec '$extDbRlsSpec'  --fileName $workflowDataDir/$inputFile";

  if ($test) {
     $self->testInputFile('inputFile', "$workflowDataDir/$inputFile");
  }else{
     $self->runPlugin($test, $undo,"GUS::Supported::Plugin::InsertSequenceFeatures", $args);
  }

}

sub getParamsDeclaration {
  return (
	  'inputFile',
	  'extDbRlsSpec',
	 );
}

sub getConfigDeclaration {
  return (
	  # [name, default, description]
	 );
}


