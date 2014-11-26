package ApiCommonWorkflow::Main::WorkflowSteps::InsertSnpMummer;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;


sub getSoTerm {
  return 'SNP';
}


sub run {
  my ($self, $test, $undo) = @_;

  my $inputFile = $self->getParamValue('inputFile');
  my $organismAbbrev = $self->getParamValue('organismAbbrev');
  my $genomeExtDbRlsSpec = $self->getParamValue('genomeExtDbRlsSpec');
  my $transcriptExtDbRlsSpec = $self->getParamValue('transcriptExtDbRlsSpec');
  my $snpExtDbRlsSpec = $self->getParamValue('snpExtDbRlsSpec');
  my $isNextGenSeq = $self->getBooleanParamValue('isNextGenSeq');
  my $isCoverage = $self->getBooleanParamValue('isCoverage');

  my $soExtDbName = $self->getSharedConfig("sequenceOntologyExtDbName");

  my ($genomExtDbName,$genomeExtDbRlsVer) = $self->getExtDbInfo($test,$genomeExtDbRlsSpec);
  my ($snpExtDbName,$snpExtDbRlsVer) = $self->getExtDbInfo($test,$snpExtDbRlsSpec);
  my ($transcriptExtDbName,$transcriptExtDbRlsVer) = $self->getExtDbInfo($test,$transcriptExtDbRlsSpec);

  my $organismFullName = $self->getOrganismInfo($test, $organismAbbrev)->getFullName();
  my $strainAbbrev = $self->getOrganismInfo($test, $organismAbbrev)->getStrainAbbrev();
  
  unless($strainAbbrev) {
    $self->error("Strain Abbreviation for the reference [$organismAbbrev] was not defined");   
  }

  my $workflowDataDir = $self->getWorkflowDataDir();

  my $soTerm = $self->getSoTerm();

  my $args = "--reference '$strainAbbrev' --organism '$organismFullName' --snpExternalDatabaseName '$snpExtDbName' --snpExternalDatabaseVersion '$snpExtDbRlsVer' --naExternalDatabaseName '$genomExtDbName' --naExternalDatabaseVersion '$genomeExtDbRlsVer' --transcriptExternalDatabaseName '$transcriptExtDbName' --transcriptExternalDatabaseVersion '$transcriptExtDbRlsVer' --seqTable 'DoTS::ExternalNASequence' --ontologyTerm $soTerm --snpFile $workflowDataDir/$inputFile --soExtDbSpec '$soExtDbName|%'";

  $args .= " --NGS_SNP" if ($isNextGenSeq);
  $args .= " --NgsUpdateSnpFeature" if ($isCoverage);

    $self->testInputFile('inputFile', "$workflowDataDir/$inputFile");
    
    $self->runPlugin($test, $undo, "ApiCommonData::Load::Plugin::InsertSnps", $args);
}

1;

