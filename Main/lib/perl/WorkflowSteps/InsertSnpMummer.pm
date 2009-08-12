package ApiCommonWorkflow::Main::WorkflowSteps::InsertSnpMummer;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;


sub run {
  my ($self, $test, $undo) = @_;

  my $inputFile = $self->getParamValue('inputFile');
  my $strain = $self->getParamValue('strain');
  my $organismFullName = $self->getParamValue('organismFullName');
  my $genomeExtDbRlsSpec = $self->getParamValue('genomeExtDbRlsSpec');
  my $transcriptExtDbRlsSpec = $self->getParamValue('transcriptExtDbRlsSpec');
  my $snpExtDbRlsSpec = $self->getParamValue('snpExtDbRlsSpec');

  my ($genomExtDbName,$genomeExtDbRlsVer) = $self->getExtDbInfo($test,$genomeExtDbRlsSpec);
  my ($snpExtDbName,$snpExtDbRlsVer) = $self->getExtDbInfo($test,$snpExtDbRlsSpec);
  my ($transcriptExtDbName,$transcriptExtDbRlsVer) = $self->getExtDbInfo($test,$transcriptExtDbRlsSpec);

  my $localDataDir = $self->getLocalDataDir();

  my $args = "--reference '$strain' --organism '$organismFullName' --snpExternalDatabaseName '$snpExtDbName' --snpExternalDatabaseVersion '$snpExtDbRlsVer' --naExternalDatabaseName '$genomExtDbName' --naExternalDatabaseVersion '$genomeExtDbRlsVer' --transcriptExternalDatabaseName '$transcriptExtDbName' --transcriptExternalDatabaseVersion '$transcriptExtDbRlsVer' --seqTable 'DoTS::ExternalNASequence' --ontologyTerm 'SNP' --snpFile $localDataDir/$inputFile";

  if ($test) {
    $self->testInputFile('inputFile', "$localDataDir/$inputFile");
  }

  $self->runPlugin($test, $undo, "ApiCommonWorkflow::Main::Plugin::InsertSnps", $args);

}

sub getParamDeclaration {
  return (
	  'inputFile',
	  'genomeExtDbRlsSpec',
	  'strain',
	  'organismFullName',
	  'transcriptExtDbRlsSpec',
	  'snpExtDbRlsSpec',
	 );
}

sub getConfigDeclaration {
  return (
	  # [name, default, description]
	 );
}

