package ApiCommonWorkflow::Main::WorkflowSteps::ExtractTopLevelFastaSeqs;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test, $undo) = @_;


  my $organismFullName = $self->getParamValue('organismFullName');
  my $outputFile = $self->getParamValue('outputFile');


  my $sql = "select sa.na_sequence_id,ns.sequence from apidbtuning.sequenceattributes sa, dots.nasequence ns where sa.na_sequence_id in (select na_sequence_id from apidbtuning.featurelocation where is_top_level = 1) and sa.na_sequence_id = ns.na_sequence_id and sa.organism in ('$organismFullName')";

  my $workflowDataDir = $self->getWorkflowDataDir();

    if ($undo) {
      $self->runCmd(0, "rm -f $workflowDataDir/$outputFile");
    } else {
	if ($test) {
	    $self->runCmd(0,"echo test > $workflowDataDir/$outputFile");
	}else{
	    $self->runCmd($test,"dumpSequencesFromTable.pl --outputFile $workflowDataDir/$outputFile --idSQL \"$sql\" --verbose")  if ($genomeVirtualSeqsExtDbRlsSpec);

	}
    }
  }

sub getParamsDeclaration {
  return (
	  'organismFullName',
	  'outputFile',
	 );
}

sub getConfigDeclaration {
  return (
	  # [name, default, description]
	 );
}


