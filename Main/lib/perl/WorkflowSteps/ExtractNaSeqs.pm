package ApiCommonWorkflow::Main::WorkflowSteps::ExtractNaSeqs;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test, $undo) = @_;

  my $table = $self->getParamValue('table');
  my $extDbName = $self->getParamValue('extDbName');
  my $alternateDefline = $self->getParamValue('alternateDefline');
  my $outputFile = $self->getParamValue('outputFile');
  my $separateFastaFiles = $self->getBooleanParamValue('separateFastaFiles');
  my $outputDirForSeparateFiles = $self->getParamValue('outputDirForSeparateFiles');


  my @extDbNameList = split(/,/, $extDbName);

  my $dbRlsIds;

  foreach my $dbName (@extDbNameList){
        
      my $dbVer = $self->getExtDbVersion($test, $dbName);
     $dbRlsIds .= $self->getExtDbRlsId($test, "$dbName|$dbVer").",";

  }

  $dbRlsIds =~ s/(,)$//g;

  my $deflineSelect = $alternateDefline?
    $alternateDefline :
      "source_id, description, 'length='||length";

  my $sql = "SELECT $deflineSelect, sequence
             FROM dots.$table
             WHERE external_database_release_id in ($dbRlsIds)";

  my $workflowDataDir = $self->getWorkflowDataDir();

  if ($separateFastaFiles) {

    $self ->runCmd(0,"mkdir -p $workflowDataDir/$outputDirForSeparateFiles");

    if ($undo) {
      $self->runCmd(0, "rm -rf $workflowDataDir/$outputDirForSeparateFiles");
    } else {
	if ($test) {
	    $self->runCmd(0,"echo test > $workflowDataDir/$outputDirForSeparateFiles/IndividualSeqTest.out");
	}
        $self->runCmd($test,"gusExtractIndividualSequences --outputDir $workflowDataDir/$outputDirForSeparateFiles --idSQL \"$sql\" --verbose");
    }

  } else {

    if ($undo) {
      $self->runCmd(0, "rm -f $workflowDataDir/$outputFile");
    } else {
	if ($test) {
	    $self->runCmd(0,"echo test > $workflowDataDir/$outputFile");
	}
	$self->runCmd($test,"gusExtractSequences --outputFile $workflowDataDir/$outputFile --idSQL \"$sql\" --verbose");
    }
  }
}


1;

