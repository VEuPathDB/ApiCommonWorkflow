package ApiCommonWorkflow::Main::WorkflowSteps::ExtracttRNArRNAFastaSeqs;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test, $undo) = @_;

  my $outputFile = $self->getParamValue('outputFile');
  my $organismAbbrev = $self->getParamValue('organismAbbrev');

  my $taxonId = $self->getOrganismInfo($test, $organismAbbrev)->getTaxonId();
  my $sql = 
    "select gf.source_id, sns.sequence
     from dots.transcript t,
     dots.splicednasequence sns,
     sres.taxon tn,
     sres.sequenceontology so,
     dots.genefeature gf
     where tn.taxon_id = $taxonId
     and sns.taxon_id = tn.taxon_id
     and so.term_name in ('tRNA_encoding', 'rRNA_encoding')
     and gf.sequence_ontology_id = so.sequence_ontology_id
     and t.parent_id = gf.na_feature_id
     and t.na_sequence_id = sns.na_sequence_id
     and gf.is_pseudo = 0";

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


