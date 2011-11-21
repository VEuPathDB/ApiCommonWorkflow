package ApiCommonWorkflow::Main::WorkflowSteps::InsertSnpMummer;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;


sub run {
  my ($self, $test, $undo) = @_;

  my $inputFile = $self->getParamValue('inputFile');
  my $organismAbbrev = $self->getParamValue('organismAbbrev');
  my $genomeExtDbRlsSpec = $self->getParamValue('genomeExtDbRlsSpec');
  my $transcriptExtDbRlsSpec = $self->getParamValue('transcriptExtDbRlsSpec');
  my $snpExtDbRlsSpec = $self->getParamValue('snpExtDbRlsSpec');
  my $isNextGenSeq = $self->getParamValue('isNextGenSeq');

  my ($genomExtDbName,$genomeExtDbRlsVer) = $self->getExtDbInfo($test,$genomeExtDbRlsSpec);
  my ($snpExtDbName,$snpExtDbRlsVer) = $self->getExtDbInfo($test,$snpExtDbRlsSpec);
  my ($transcriptExtDbName,$transcriptExtDbRlsVer) = $self->getExtDbInfo($test,$transcriptExtDbRlsSpec);

  my $organismFullName = $self->getOrganismInfo($test, $organismAbbrev)->getFullName();
  my $strainAbbrev = $self->getOrganismInfo($test, $organismAbbrev)->getStrainAbbrev();

  my $workflowDataDir = $self->getWorkflowDataDir();

  my $args = "--reference '$strainAbbrev' --organism '$organismFullName' --snpExternalDatabaseName '$snpExtDbName' --snpExternalDatabaseVersion '$snpExtDbRlsVer' --naExternalDatabaseName '$genomExtDbName' --naExternalDatabaseVersion '$genomeExtDbRlsVer' --transcriptExternalDatabaseName '$transcriptExtDbName' --transcriptExternalDatabaseVersion '$transcriptExtDbRlsVer' --seqTable 'DoTS::ExternalNASequence' --ontologyTerm 'SNP' --snpFile $workflowDataDir/$inputFile";

  $args .= " --NGS_SNP" if ($isNextGenSeq eq 'true');

  if ($test) {
    $self->testInputFile('inputFile', "$workflowDataDir/$inputFile");
  }

  $self->runPlugin($test, $undo, "ApiCommonData::Load::Plugin::InsertSnps", $args);

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

