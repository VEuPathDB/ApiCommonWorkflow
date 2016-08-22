package ApiCommonWorkflow::Main::WorkflowSteps::InsertSnpMummer;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;


sub getSoTerm {
  return 'SNP';
}


sub run {
  my ($self, $test, $undo) = @_;

  my $variationFile = $self->getParamValue('variationFile');
  my $snpFile = $self->getParamValue('snpFile');

  my $snpExtDbRlsSpec = $self->getParamValue('snpExtDbRlsSpec');

  my $soExtDbName = $self->getSharedConfig("sequenceOntologyExtDbName");

  my $workflowDataDir = $self->getWorkflowDataDir();

  my $soTerm = $self->getSoTerm();

  my $args = "--variationFile $workflowDataDir/$variationFile --snpFile $workflowDataDir/$snpFile --ontologyTerm $soTerm --soExtDbSpec '$soExtDbName|%' --snpExtDbRlsSpec '$snpExtDbRlsSpec'";

    $self->testInputFile('variationFile', "$workflowDataDir/$variationFile");
    $self->testInputFile('snpFile', "$workflowDataDir/$snpFile");
    
    $self->runPlugin($test, $undo, "ApiCommonData::Load::Plugin::InsertSnpFeatures", $args);
}

1;

