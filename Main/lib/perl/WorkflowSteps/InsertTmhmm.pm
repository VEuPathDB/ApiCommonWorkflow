package ApiCommonWorkflow::Main::WorkflowSteps::InsertTmhmm;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;


sub run {
  my ($self, $test, $undo) = @_;

  my $inputFile = $self->getParamValue('inputFile');
  my $genomeExtDbRlsSpec = $self->getParamValue('genomeExtDbRlsSpec');

  my $version = $self->getConfig('version');

  my ($extDbName,$extDbRlsVer) = $self->getExtDbInfo($test,$genomeExtDbRlsSpec);

  my $localDataDir = $self->getLocalDataDir();

  my $args = "--data_file $localDataDir/$inputFile --algName TMHMM --algDesc 'TMHMM $version' --useSourceId --extDbName '$extDbName' --extDbRlsVer '$extDbRlsVer'";

  if ($test) {
    $self->testInputFile('inputFile', "$localDataDir/$inputFile");
  }

  $self->runPlugin($test, $undo, "ApiCommonWorkflow::Main::Plugin::LoadTMDomains", $args);

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

