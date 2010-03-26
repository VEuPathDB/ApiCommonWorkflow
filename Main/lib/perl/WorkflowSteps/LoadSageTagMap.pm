package ApiCommonWorkflow::Main::WorkflowSteps::LoadSageTagMap;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;


sub run {
  my ($self, $test, $undo) = @_;

  my $inputFile = $self->getParamValue('inputFile');

  my $workflowDataDir = $self->getWorkflowDataDir();
      
  my $args = "--tagToSeqFile $workflowDataDir/$inputFile --extDbSpec 'RAD.SAGETag|continuous' --featureType SAGETagFeature";

  if ($test) {
    $self->testInputFile('inputFile', "$workflowDataDir/$inputFile");
  }

  $self->runPlugin($test, $undo, "ApiCommonData::Load::Plugin::LoadExpressionFeature", $args);

}

sub getParamDeclaration {
  return (
	  'inputFile',
	 );
}

sub getConfigDeclaration {
  return (
	  # [name, default, description]
	 );
}

