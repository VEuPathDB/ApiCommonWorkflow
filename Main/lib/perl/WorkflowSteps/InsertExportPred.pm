package ApiCommonWorkflow::Main::WorkflowSteps::InsertExportPred;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;


sub run {
  my ($self, $test, $undo) = @_;

  my $inputFile = $self->getParamValue('inputFile');
  my $genomeExtDbRlsSpec = $self->getParamValue('genomeExtDbRlsSpec');

  my $localDataDir = $self->getLocalDataDir();

  my $args = "--inputFile $localDataDir/$inputFile --seqTable DoTS::AASequence --seqExtDbRlsSpec '$genomeExtDbRlsSpec' --extDbRlsSpec '$genomeExtDbRlsSpec'";

  if ($test) {
    $self->testInputFile('inputFile', "$localDataDir/$inputFile");
  }

  $self->runPlugin($test, $undo, "ApiCommonWorkflow::Main::Plugin::InsertExportPredFeature", $args);

}

sub getParamDeclaration {
  return (
	  'inputFile',
	  'genomeExtDbRlsSpec',
	 );
}

sub getConfigDeclaration {
  return (
	  # [name, default, description]
	  ['version', "", ""],
	 );
}

