package ApiCommonWorkflow::Main::WorkflowSteps::ExtractTranscriptSeqsForSsa;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test, $undo) = @_;

  my $outputFile = $self->getParamValue('outputFile');
  my $organismAbbrev = $self->getParamValue('organismAbbrev');
  my $useTopLevel = $self->getParamValue('useTopLevel');

  my $ncbiTaxonId = $self->getOrganismInfo($test, $organismAbbrev)->getNcbiTaxonId();

  my $sql = "select ga.source_id || ':'
                    || substr(ns.source_id, 1, 50) ||':'
                    ||(nl.start_min - 1)||'-'||nl.end_max||'_'||(decode(nl.is_reversed, 1, '-', '+')),
                    snas.sequence
                          from dots.Transcript t, dots.SplicedNaSequence snas,
                               dots.GeneFeature ga, dots.NaLocation nl,
                               dots.NaSequence ns, sres.Taxon, sres.SequenceOntology so
                          where ga.na_sequence_id = ns.na_sequence_id
                            and ga.na_feature_id = t.parent_id
                            and t.na_sequence_id = snas.na_sequence_id
                            and ga.sequence_ontology_id = so.sequence_ontology_id
                            and so.term_name != 'repeat_region'
                            and snas.taxon_id = taxon.taxon_id
                            and taxon.ncbi_tax_id = $ncbiTaxonId
                            and nl.na_feature_id = ga.na_feature_id";




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


