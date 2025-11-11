package ApiCommonWorkflow::Main::WorkflowSteps::InsertGeneNamesFromTabFile;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test, $undo) = @_;

  my $inputFile = $self->getParamValue('inputFile');
  my $genomeExtDbRlsSpec = $self->getParamValue('genomeExtDbRlsSpec');

  my $workflowDataDir = $self->getWorkflowDataDir();

  $self->testInputFile('inputFile', "$workflowDataDir/$inputFile");

  # Parse the genomeExtDbRlsSpec to extract extDbName and extDbVersion
  my ($extDbName, $extDbVersion) = split(/\|/, $genomeExtDbRlsSpec);

  $self->error("Invalid genomeExtDbRlsSpec format: '$genomeExtDbRlsSpec'. Expected format: 'extDbName|extDbVersion'")
    unless defined $extDbName && defined $extDbVersion;

  my $args = "--file $workflowDataDir/$inputFile"
    . " --geneNameDbName '$extDbName'"
    . " --geneNameDbVer '$extDbVersion'";

  $self->runPlugin($test, $undo, "ApiCommonData::Load::Plugin::InsertGeneNamesFromTabFile", $args);
}

1;
