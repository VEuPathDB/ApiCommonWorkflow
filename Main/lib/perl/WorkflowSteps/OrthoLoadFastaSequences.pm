package ApiCommonWorkflow::Main::WorkflowSteps::OrthoLoadFastaSequences;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test, $undo) = @_;

  my $edn = $self->getParamValue('externalDatabaseName');
  my $edv = $self->getParamValue('externalDatabaseVersion');
  my $ncbi = $self->getParamValue('ncbiTaxonId'); 
  my $file = $self->getParamValue('sequenceFile');  
  my $name = $self->getParamValue('regexName');
  my $desc = $self->getParamValue('regexDesc');
  my $second = $self->getParamValue('regexSecondaryId');
  my $source = $self->getParamValue('regexSourceId');
  my $table = $self->getParamValue('tableName');
  my $isCore = $self->getParamValue('isCore');

  my $workflowDataDir = $self->getWorkflowDataDir();
  my $gusConfigFile = $self->getParamValue('gusConfigFile');
  $gusConfigFile = $workflowDataDir . "/" . $gusConfigFile;

  my $args = "--externalDatabaseName $edn --externalDatabaseVersion $edv --sequenceFile $workflowDataDir/$file --regexSourceId '$source' --regexSecondaryId '$second' --regexName '$name' --isCore $isCore --regexDesc '$desc' --tableName \"$table\" --ncbiTaxId $ncbi --gusConfigFile $gusConfigFile ";

  $args .= "--ncbiTaxId $ncbi " if ($ncbi);

  $self->testInputFile('inputFile', "$workflowDataDir/$file") unless ($undo);

  $self->runPlugin($test, $undo, "GUS::Supported::Plugin::LoadFastaSequences", $args);
}

1;
