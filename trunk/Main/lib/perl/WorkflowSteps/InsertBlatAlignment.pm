package ApiCommonWorkflow::Main::WorkflowSteps::InsertBlatAlignment;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test, $undo) = @_;

  my $targetNcbiTaxId = $self->getParamValue('targetNcbiTaxId');
  my $targetExtDbRlsSpec = $self->getParamValue('targetExtDbRlsSpec');
  my $targetTable = $self->getParamValue('targetTable');
  my $queryNcbiTaxId = $self->getParamValue('queryNcbiTaxId');
  my $queryExtDbRlsSpec = $self->getParamValue('queryExtDbRlsSpec');
  my $queryTable = $self->getParamValue('queryTable');
  my $queryFile = $self->getParamValue('queryFile');
  my $regex = $self->getParamValue('regex');
  my $action = $self->getParamValue('action');
  my $percentTop = $self->getParamValue('percentTop');
  my $blatFile = $self->getParamValue('blatFile');

  my $targetTaxonId = $self->getTaxonIdFromNcbiTaxId($test,$targetNcbiTaxId);
  my $targetTableId = $self->getTableId($targetTable);
  my $targetExtDbRlsId = $self->getExtDbRlsId($test, $targetExtDbRlsSpec);
  my $queryTaxonId = $self->getTaxonIdFromNcbiTaxId($test,$queryNcbiTaxId);
  my $queryTableId = $self->getTableId($queryTable);
  my $queryExtDbRlsId = $self->getExtDbRlsId($test, $queryExtDbRlsSpec) if $queryExtDbRlsSpec;

  my $workflowDataDir = $self->getWorkflowDataDir();

  my $args = "--blat_files '$workflowDataDir/$blatFile' --query_file $workflowDataDir/$queryFile --action '$action' --queryRegex '$regex' --query_table_id $queryTableId --query_taxon_id $queryTaxonId --target_table_id  $targetTableId --target_db_rel_id $targetExtDbRlsId --target_taxon_id $targetTaxonId --max_query_gap 5 --min_pct_id 95 --max_end_mismatch 10 --end_gap_factor 10 --min_gap_pct 90  --ok_internal_gap 15 --ok_end_gap 50 --min_query_pct 10";

  $args .= " --query_db_rel_id $queryExtDbRlsId" if $queryExtDbRlsId;

  $args .= " --percentTop $percentTop" if $percentTop;

  if ($test) {
    $self->testInputFile('queryFile', "$workflowDataDir/$queryFile");
    $self->testInputFile('blatFile', "$workflowDataDir/$blatFile");
  }

  $self->runPlugin($test, $undo,"GUS::Community::Plugin::LoadBLATAlignments", $args);
}

sub getParamDeclaration {
  return (
	  'targetTaxonId',
	  'queryTaxonId',
	  'targetExtDbRlsSpec',
	  'queryExtDbRlsSpec',
	  'regex',
	  'action',
	  'percentTop',
	  'blatFile',
	  'queryFile',
	  'targetTable',
	  'queryTable',
	 );
}

sub getConfigDeclaration {
  return (
	  # [name, default, description]
	 );
}

