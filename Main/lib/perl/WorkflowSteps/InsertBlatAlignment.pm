package ApiCommonWorkflow::Main::WorkflowSteps::InsertBlatAlignment;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test, $undo) = @_;

  # NOTE: this step class takes a shortcut.  it assumes that the query ncbi taxon id is for the species
  # this might not be true for future uses of this class.  best solution is to remove the need
  # for taxon IDs at all, which will involve changing the plugin. see redmine #5520

  my $organismAbbrev = $self->getParamValue('organismAbbrev');
  my $targetExtDbName = $self->getParamValue('targetExtDbName');
  my $targetTable = $self->getParamValue('targetTable');
  my $queryExtDbName = $self->getParamValue('queryExtDbName');
  my $queryTable = $self->getParamValue('queryTable');
  my $queryFile = $self->getParamValue('queryFile');
  my $queryRegex = $self->getParamValue('queryIdRegex');
  my $action = $self->getParamValue('action');
  my $percentTop = $self->getParamValue('percentTop');
  my $blatFile = $self->getParamValue('blatFile');

  my $targetTaxonId = $self->getOrganismInfo($test, $organismAbbrev)->getTaxonId();
  my $queryTaxonId = $self->getOrganismInfo($test, $organismAbbrev)->getSpeciesTaxonId();

  my $targetTableId = $self->getTableId($test, $targetTable);
  my $targetExtDbVer = $self->getExtDbVersion($test,$targetExtDbName);
  my $targetExtDbRlsId = $self->getExtDbRlsId($test, "$targetExtDbName|$targetExtDbVer");
  my $queryTableId = $self->getTableId($test, $queryTable);
  my $queryExtDbRlsId;
  if ($queryExtDbName) {
      my $queryExtDbVer = $self->getExtDbVersion($test,$queryExtDbName);
      my $queryExtDbRlsId = $self->getExtDbRlsId($test, "$queryExtDbName|$queryExtDbVer");
  }

  my $workflowDataDir = $self->getWorkflowDataDir();

  my $plugin = "GUS::Community::Plugin::LoadBLATAlignments";
  my $loadedTable = "DoTS.BlatAlignment";
  my $dnaArgs = "--max_query_gap 5 --min_pct_id 95 --max_end_mismatch 10 --end_gap_factor 10 --min_gap_pct 90  --ok_internal_gap 15 --ok_end_gap 50 --min_query_pct 10";

  if ($queryTable =~ /aasequence/i) {
      $dnaArgs = "";
      $plugin = "ApiCommonData::Load::Plugin::LoadBLATProteinAlignments";
      $loadedTable = "ApiDB.BlatProteinAlignment";
  }
      
  my $args = "--blat_files '$workflowDataDir/$blatFile' --query_file $workflowDataDir/$queryFile --action '$action' --queryRegex '$queryRegex' --query_table_id $queryTableId --query_taxon_id $queryTaxonId --target_table_id  $targetTableId --target_db_rel_id $targetExtDbRlsId --target_taxon_id $targetTaxonId $dnaArgs";

  $args .= " --query_db_rel_id $queryExtDbRlsId" if $queryExtDbRlsId;

  $args .= " --percentTop $percentTop" if $percentTop;


    $self->testInputFile('queryFile', "$workflowDataDir/$queryFile");
    $self->testInputFile('blatFile', "$workflowDataDir/$blatFile");


  if (-s "$workflowDataDir/$queryFile" || $test) {
      $self->runPlugin($test, $undo, $plugin, $args);
  } else {
      $self->log("queryFile '$workflowDataDir/$queryFile' is empty.  Doing nothing.");      
  }
  #check the number of rows loaded. We will put a threshold for it, say if less than 1000 rows, the step will fail.
  if ($action eq 'load' && !$test && !$undo){
       my $algInvIds = $self->getAlgInvIds();
       my $sql = "select count(*) from $loadedTable where row_alg_invocation_id in ($algInvIds)";
       my $cmd = "getValueFromTable --idSQL \"$sql\"";
       my $loaded = $self->runCmd($test, $cmd);
       die "Less than 1000 rows loaded." if ($loaded < 1000);     
  }
}

1;

