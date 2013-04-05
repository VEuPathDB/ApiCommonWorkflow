package ApiCommonWorkflow::Main::WorkflowSteps::InsertMassSpecResults;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;


sub run {
  my ($self, $test, $undo) = @_;

  my $inputDir = $self->getParamValue('inputDir');
  my $organismAbbrev = $self->getParamValue('organismAbbrev');
  my $genomeExtDbRlsSpec = $self->getParamValue('genomeExtDbRlsSpec');
  my $massSpecExtDbRlsSpec = $self->getParamValue('massSpecExtDbRlsSpec');
  my $fileNameRegEx = $self->getParamValue('fileNameRegEx')

  my ($genomExtDbName,$genomeExtDbRlsVer) = $self->getExtDbInfo($test,$genomeExtDbRlsSpec);
  my ($massSpecExtDbName,$massSpecExtDbRlsVer) = $self->getExtDbInfo($test,$massSpecExtDbRlsSpec);

  my $workflowDataDir = $self->getWorkflowDataDir();

  my $args = "--inputDir $inpuDir --externalDatabaseSpec $massSpecExtDbRlsSpec --geneExternalDatabaseSpec $genomeExtDbRlsSpec --fileNameRegEx $fileNameRegEx";

  if ($test) {
    $self->testInputFile('inputFile', "$workflowDataDir/$inputFile");
  }

  $self->runPlugin($test, $undo, "ApiCommonData::Load::Plugin::InsertMassSpec", $args);

}

sub getParamDeclaration {
  return (
	  'inputFile',
	  'organismAbbrev'
	  'genomeExtDbRlsSpec',
	  'massSpecExtDbRlsSpec',
	  'snpExtDbRlsSpec',
	  'fileNameRegEx',
	 );
}

sub getConfigDeclaration {
  return (
	  # [name, default, description]
	 );
}
