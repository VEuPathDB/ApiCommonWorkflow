package ApiCommonWorkflow::Main::WorkflowSteps::ExtractNaSeqsForSsa;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test, $undo) = @_;

  my $outputFile = $self->getParamValue('outputFile');
  my $organismAbbrev = $self->getParamValue('organismAbbrev');

  my $ncbiTaxonId = $self->getOrganismInfo($test, $organismAbbrev)->getNcbiTaxonId();

  my $sql = "select sa.source_id||':1-'||sa.length||'_strand=+',ns.sequence 
             from apidb.sequenceattributes sa, dots.nasequence ns 
             where sa.na_sequence_id = ns.na_sequence_id
             and sa.NCBI_TAX_ID = $ncbiTaxonId and is_top_level = 1";


  my $workflowDataDir = $self->getWorkflowDataDir();

  if ($undo) {
      $self->runCmd(0, "rm -f $workflowDataDir/$outputFile");
      $self->runCmd(0, "rm -f $workflowDataDir/$outputFile.multiLine");
  } else {
      if ($test) {
	    $self->runCmd(0,"echo test > $workflowDataDir/$outputFile");
      }else{
	    $self->runCmd($test,"gusExtractSequences --outputFile $workflowDataDir/$outputFile.multiLine --idSQL \"$sql\" --verbose");
	    $self->runCmd($test,"modify_fa_to_have_seq_on_one_line.pl $workflowDataDir/$outputFile.multiLine >$workflowDataDir/$outputFile");
      }
  }
}

sub getConfigDeclaration {
  return (
	  # [name, default, description]
	 );
}


