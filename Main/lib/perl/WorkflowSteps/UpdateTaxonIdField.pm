package ApiCommonWorkflow::Main::WorkflowSteps::UpdateTaxonIdField;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;


sub run {
  my ($self, $test,$undo) = @_;

  my $mappingFileRelativeToDownloadDir = $self->getParamValue('mappingFileRelativeToDownloadDir');
  my $sourceIdRegex = $self->getParamValue('sourceIdRegex');
  my $taxonRegex = $self->getParamValue('taxonRegex');
  my $idSql = $self->getParamValue('idSql');
  my $extDbRlsSpec = $self->getParamValue('extDbRlsSpec');
  my $tableName = $self->getParamValue('tableName');
 
  my $downloadDir = $self->getSharedConfig('downloadDir');

  my $mappingFile = "$downloadDir/$mappingFileRelativeToDownloadDir";

  my $args = "--fileName '$mappingFile' --sourceIdRegex  \"$sourceIdRegex\" $taxonRegex --idSql '$idSql' --extDbRelSpec '$extDbRlsSpec'  --tableName '$tableName'";

  $self->testInputFile('mappingFile', "$mappingFile");

  $self->runPlugin($test, $undo, "ApiCommonData::Load::Plugin::UpdateTaxonFieldFromFile", $args);

}


1;




