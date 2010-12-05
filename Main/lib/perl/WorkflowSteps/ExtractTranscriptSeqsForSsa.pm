package ApiCommonWorkflow::Main::WorkflowSteps::ExtractTranscriptSeqsForSsa;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test, $undo) = @_;

  my $outputFile = $self->getParamValue('outputFile');
  my $ncbiTaxonId = $self->getParamValue('ncbiTaxonId');



  my $sql = "SELECT ga.source_id||':'||ga.sequence_id||':'||ga.start_min||'-'||ga.end_max||'_'||(decode(ga.is_reversed, 1, '-', '+')), snas.sequence
             FROM dots.transcript t,
                  dots.splicednasequence snas,
                  apidb.geneattributes ga
             WHERE ga.na_feature_id = t.parent_id
              AND t.na_sequence_id = snas.na_sequence_id
              AND ga.so_term_name != 'repeat_region'
              AND ga.ncbi_tax_id = $ncbiTaxonId";




  my $workflowDataDir = $self->getWorkflowDataDir();

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

sub getParamsDeclaration {
  return (
	  'outputFile',
	  'ncbiTaxonId'
	 );
}

sub getConfigDeclaration {
  return (
	  # [name, default, description]
	 );
}


