package ApiCommonWorkflow::Main::WorkflowSteps::ExtractNaSeqs;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test, $undo) = @_;

  my $table = $self->getParamValue('table');
  my $extDbRlsSpec = $self->getParamValue('extDbRlsSpec');
  my $alternateDefline = $self->getParamValue('alternateDefline');
  my $outputFile = $self->getParamValue('outputFile');
  my $separateFastaFiles = $self->getParamValue('separateFastaFiles');
  my $outputDirForSeparateFiles = $self->getParamValue('outputDirForSeparateFiles');


  my @extDbRlsSpecList = split(/,/, $extDbRlsSpec);

  my $dbRlsIds;

  foreach my $db (@extDbRlsSpecList){
        
     $dbRlsIds .= $self->getExtDbRlsId($test, $db).",";

  }

  $dbRlsIds =~ s/(,)$//g;

  my $deflineSelect = $alternateDefline?
    $alternateDefline :
      "source_id, description, 'length='||length";

  my $sql = "SELECT $deflineSelect, sequence
             FROM dots.$table
             WHERE external_database_release_id in ($dbRlsIds)";

  my $workflowDataDir = $self->getWorkflowDataDir();

  if ($separateFastaFiles eq 'true') {

    $self ->runCmd(0,"mkdir -p $workflowDataDir/$outputDirForSeparateFiles");

    if ($undo) {
      $self->runCmd(0, "rm -rf $workflowDataDir/$outputDirForSeparateFiles");
    } else {
	if ($test) {
	    $self->runCmd(0,"echo test > $workflowDataDir/$outputDirForSeparateFiles/IndividualSeqTest.out");
	}else{
	    $self->runCmd($test,"gusExtractIndividualSequences --outputDir $workflowDataDir/$outputDirForSeparateFiles --idSQL \"$sql\" --verbose");
	}
    }

  } else {

    if ($undo) {
      $self->runCmd(0, "rm -f $workflowDataDir/$outputFile");
    } else {
	if ($test) {
	    $self->runCmd(0,"echo test > $workflowDataDir/$outputFile");
	}else{
	    $self->runCmd($test,"gusExtractSequences --outputFile $workflowDataDir/$outputFile --idSQL \"$sql\" --verbose");
	}
    }
  }
}
sub getParamsDeclaration {
  return (
	  'table',
	  'extDbRlsSpec',
	  'alternateDefline',
	  'separateFastaFiles',
	  'outputFile',
	  'outputDirForSeparateFiles'
	 );
}

sub getConfigDeclaration {
  return (
	  # [name, default, description]
	 );
}


