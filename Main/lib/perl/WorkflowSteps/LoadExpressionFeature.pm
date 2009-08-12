package ApiCommonWorkflow::Main::WorkflowSteps::LoadExpressionFeature;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;


sub run {
  my ($self, $test, $undo) = @_;

  my $inputFile = $self->getParamValue('inputFile');

  my $extDbRlsSpec = $self->getParamValue('extDbRlsSpec');

  my $featureType = $self->getParamValue('featureType');

  my $localDataDir = $self->getLocalDataDir();
      
  my $args = "--tagToSeqFile $localDataDir/$inputFile --extDbSpec '$extDbRlsSpec' --featureType $featureType";

  if ($test) {
    $self->testInputFile('inputFile', "$localDataDir/$inputFile");
  }

  $self->runPlugin($test, $undo, "ApiCommonWorkflow::Main::Plugin::LoadExpressionFeature", $args);

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

