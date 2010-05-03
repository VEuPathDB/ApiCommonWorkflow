package ApiCommonWorkflow::Main::WorkflowSteps::ExtractTranscriptSeqsForSsa;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test, $undo) = @_;

  my $extDbRlsSpec = $self->getParamValue('extDbRlsSpec');
  my $outputFile = $self->getParamValue('outputFile');
  my $ncbiTaxonId = $self->getParamValue('ncbiTaxonId');


  my @extDbRlsSpecList = split(/,/, $extDbRlsSpec);

  my $dbRlsIds;

  foreach my $db (@extDbRlsSpecList){
        
     $dbRlsIds .= $self->getExtDbRlsId($test, $db).",";

  }

  $dbRlsIds =~ s/(,)$//g;

  my $taxonId = $self->getTaxonIdFromNcbiTaxId($test,$ncbiTaxonId);

  my $sql = "SELECT gf.source_id||':'||enas.source_id||':'||nl.start_min||'-'||nl.end_max||'_'||(decode(nl.is_reversed, 1, '-', '+')), snas.sequence 
             FROM dots.genefeature gf, 
                  dots.transcript t, 
                  dots.splicednasequence snas,
                  dots.ExternalNASequence enas, 
                  sres.sequenceontology so,
                  dots.nalocation nl
            WHERE gf.na_feature_id = t.parent_id
              AND t.na_sequence_id = snas.na_sequence_id
              AND gf.na_sequence_id = enas.na_sequence_id
              AND gf.sequence_ontology_id = so.sequence_ontology_id
              AND so.term_name != 'repeat_region'
              AND snas.taxon_id = $taxonId
              AND gf.na_feature_id = nl.na_feature_id";

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

sub getParamsDeclaration {
  return (
	  'extDbRlsSpec',
	  'outputFile',
	  'ncbiTaxonId'
	 );
}

sub getConfigDeclaration {
  return (
	  # [name, default, description]
	 );
}


