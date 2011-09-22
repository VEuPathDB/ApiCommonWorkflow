package ApiCommonWorkflow::Main::WorkflowSteps::ExtractNaSeqsForSsa;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test, $undo) = @_;

  my $outputFile = $self->getParamValue('outputFile');
  my $organismAbbrev = $self->getParamValue('organismAbbrev');

  my $ncbiTaxonId = $self->getOrganismInfo($test, $organismAbbrev)->getNcbiTaxonId();

  my $sql = "select ns.source_id||':1-'||ns.length||'_strand=+', ns.sequence
             from dots.NaSequence ns, sres.Taxon t, sres.SequenceOntology so
             where ns.taxon_id = t.taxon_id
               and t.ncbi_tax_id = $ncbiTaxonId
               and ns.sequence_ontology_id = so.sequence_ontology_id
               and so.term_name != 'EST'
               and so.term_name != 'oligo'
               and so.term_name != 'mature_transcript'
               and so.term_name != 'assembly'";


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


