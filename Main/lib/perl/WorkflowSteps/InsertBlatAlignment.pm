package ApiCommonWorkflow::Main::WorkflowSteps::InsertBlatAlignment;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;
#use File::Temp qw/ tempfile /;

sub run {
  my ($self, $test, $undo) = @_;

  # NOTE: this step class takes a shortcut.  it assumes that the query ncbi taxon id is for the species
  # this might not be true for future uses of this class.  best solution is to remove the need
  # for taxon IDs at all, which will involve changing the plugin. see redmine #5520

  my $organismAbbrev = $self->getParamValue('organismAbbrev');
  my $targetExtDbRlsSpec = $self->getParamValue('targetExtDbRlsSpec');
  my $targetTable = $self->getParamValue('targetTable');
  my $queryExtDbName = $self->getParamValue('queryExtDbName');
  my $queryTable = $self->getParamValue('queryTable');
  my $queryFile = $self->getParamValue('queryFile');
  my $gusConfigFile = $self->getParamValue('gusConfigFile');
  $gusConfigFile = $self->getWorkflowDataDir() . "/$gusConfigFile";
 
  my $queryRegex = '>(\S+)'; # this is the default and is used for all DNA Blat

  my $action = $self->getParamValue('action');
  my $percentTop = $self->getParamValue('percentTop');
  my $blatFile = $self->getParamValue('blatFile');

  my $targetTaxonId = $self->getOrganismInfo($test, $organismAbbrev, $gusConfigFile)->getTaxonId();
  #my $queryTaxonId = $self->getOrganismInfo($test, $organismAbbrev, $gusConfigFile)->getSpeciesTaxonId();
  my $speciesNcbiTaxonId = $self->getParamValue('speciesNcbiTaxonId'); 
  my $speciesTaxonId = $self->getTaxonIdFromNcbiTaxId($test, $speciesNcbiTaxonId);

  my $targetTableId = $self->getTableId($test, $targetTable);
  my $targetExtDbRlsId = $self->getExtDbRlsId($test, $targetExtDbRlsSpec);
  my $queryTableId = $self->getTableId($test, $queryTable);
  my $queryExtDbRlsId;
  if ($queryExtDbName) {
      my $queryExtDbVer = $self->getExtDbVersion($test,$queryExtDbName);
      $queryExtDbRlsId = $self->getExtDbRlsId($test, "$queryExtDbName|$queryExtDbVer");
  }

  my $workflowDataDir = $self->getWorkflowDataDir();

  my $queryTempFile = $queryFile;
  my $blatTempFile = $blatFile;
  $queryTempFile =~ s/blocked.seq/tempMappingBlocked.seq/;
  $blatTempFile =~ s/blat.psl/tempMappingBlat.psl/;
  my $hasTempFiles = 0;
  my $checkEsts = `head -n 1 $workflowDataDir/$queryFile`;
#  print "EST header is $checkEsts\n";
#  my $toloadQueryFile = $workflowDataDir."/".$queryFile;
#  my $toloadBlatFile = $workflowDataDir."/".$blatFile;
  if ($checkEsts =~/^>assemblySeqIds/){
      $hasTempFiles = 1;
      $self->log("matching regex >assemblySeqIds");
#      my ($queryTempFh,$queryTempfile) = tempfile(DIR =>$workflowDataDir);
#      my ($blatTempFh, $blatTempfile) = tempfile(DIR =>$workflowDataDir);
     my $cmd = "mapAssemblySeqIdsSourceIds --queryFile $workflowDataDir/$queryFile -blatFile $workflowDataDir/$blatFile -queryOut $workflowDataDir/$queryTempFile -blatOut $workflowDataDir/$blatTempFile --gusConfigFile $gusConfigFile";
      $self->runCmd(0, $cmd) if ($action eq 'load' && !$undo);
      $self->log("query Temp file is $workflowDataDir/$queryTempFile");
#      $self->setParamValue('queryFile', $queryTempfile);
#      $self->setParamValue('blatFile', $blatTempfile);
      $queryFile = $queryTempFile;
      $blatFile = $blatTempFile;
#      $queryFile =~ s/$workflowDataDir\///;
#      $blatFile =~ s/$workflowDataDir\///;
#      $toloadQueryFile =$queryTempfile;
#      $toloadBlatFile = $blatTempfile;
 }
 # $queryFile = $self->getParamValue('queryFile');
 # $blatFile = $self->getParamValue('blatFile');

  $self->log("queryFile is $queryFile");
  my $plugin = "GUS::Community::Plugin::LoadBLATAlignments";
  my $loadedTable = "DoTS.BlatAlignment";
  my $dnaArgs = "--max_query_gap 5 --min_pct_id 95 --max_end_mismatch 10 --end_gap_factor 10 --min_gap_pct 90  --ok_internal_gap 15 --ok_end_gap 50 --min_query_pct 10";

  if ($queryTable =~ /aasequence/i) {
      $dnaArgs = "";
      $plugin = "ApiCommonData::Load::Plugin::LoadBLATProteinAlignments";
      $loadedTable = "ApiDB.BlatProteinAlignment";
      $queryRegex = $self->getParamValue('queryIdRegex');
  }
      
  my $args = "--blat_files $workflowDataDir/$blatFile --query_file $workflowDataDir/$queryFile --action '$action' --queryRegex '$queryRegex' --query_table_id $queryTableId --query_taxon_id $speciesTaxonId --target_table_id  $targetTableId --target_db_rel_id $targetExtDbRlsId --target_taxon_id $targetTaxonId $dnaArgs";

  $args .= " --query_db_rel_id $queryExtDbRlsId" if $queryExtDbRlsId;

  $args .= " --percentTop $percentTop" if $percentTop;


    #$self->testInputFile('queryFile', "$workflowDataDir/$queryFile") if ($action eq 'load' && !$undo);;
    #$self->testInputFile('blatFile', "$workflowDataDir/$blatFile") if ($action eq 'load' && !$undo);;


  if (-s "$workflowDataDir/$queryFile" || $test) {
    $self->runPlugin($test, $undo, $plugin, $args);
  } else {
    $self->log("queryFile '$workflowDataDir/$queryFile' is empty.  Doing nothing.");
  }
  #check the number of rows loaded. We will put a threshold for it, say if less than 1000 rows, the step will fail. Can't do this, can't predict the number of ESTs
  if ($action eq 'load' && !$test && !$undo){
    my $algInvIds = $self->getAlgInvIds();
    my $sql = "select count(*) from $loadedTable where row_alg_invocation_id in ($algInvIds)";

    my $gusConfigFile = "--gusConfigFile \"" . $self->getGusConfigFile() . "\"";

    my $cmd = "getValueFromTable --idSQL \"$sql\" $gusConfigFile";

    my $loaded = $self->runCmd($test, $cmd);
    die "No rows loaded." if ($loaded == 0);
  }
  if ($undo) {
    if ($hasTempFiles == 1) {
      my $cmd = "rm -f $workflowDataDir/$queryTempFile $workflowDataDir/$blatTempFile";
      $self->runCmd(0,$cmd);
      $self->runPlugin($test, $undo, $plugin, $args);
    }
  }
}

1;

