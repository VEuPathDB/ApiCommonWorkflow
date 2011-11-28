package ApiCommonWorkflow::Main::WorkflowSteps::ExtractTopLevelFastaSeqs;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test, $undo) = @_;

  my $outputFile = $self->getParamValue('outputFile');
  my $organismAbbrev = $self->getParamValue('organismAbbrev');

  my $ncbiTaxonId = $self->getOrganismInfo($test, $organismAbbrev)->getNcbiTaxonId();
  my $sql = 
    "select sa.source_id, ns.sequence
     from apidbtuning.sequenceattributes sa, dots.nasequence ns
     where sa.na_sequence_id in (
       select na_sequence_id
       from apidbtuning.featurelocation
       where is_top_level = 1)
     and sa.na_sequence_id = ns.na_sequence_id
     and sa.NCBI_TAX_ID = $ncbiTaxonId";

   my $workflowDataDir = $self->getWorkflowDataDir();


    if ($undo) {
      $self->runCmd(0, "rm -f $workflowDataDir/$outputFile");
    } else {
	if ($test) {
	    $self->runCmd(0,"echo test > $workflowDataDir/$outputFile");
	}else{
	    $self->runCmd($test,"dumpSequencesFromTable.pl --outputFile $workflowDataDir/$outputFile --idSQL \"$sql\" --verbose");
	}
    }
  }

sub getConfigDeclaration {
  return (
	  # [name, default, description]
	 );
}


