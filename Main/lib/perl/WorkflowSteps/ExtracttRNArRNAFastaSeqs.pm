package ApiCommonWorkflow::Main::WorkflowSteps::ExtracttRNArRNAFastaSeqs;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test, $undo) = @_;

  my $outputFile = $self->getParamValue('outputFile');
  my $organismAbbrev = $self->getParamValue('organismAbbrev');
  my $gusConfigFile = $self->getParamValue('gusConfigFile');
  $gusConfigFile = $self->getWorkflowDataDir() . "/$gusConfigFile";

  my $taxonId = $self->getOrganismInfo($test, $organismAbbrev, $gusConfigFile)->getTaxonId();
  my $sql = 
    "select gf.source_id
    , sns.sequence
    from dots.transcript t
    , dots.splicednasequence sns
    , sres.taxon tn
    , sres.ontologyterm ot
    , dots.genefeature gf
    where tn.taxon_id = $taxonId
    and sns.taxon_id = tn.taxon_id
    and ot.name in ('tRNA_encoding', 'rRNA_encoding', 'ncRNA_gene')
    and gf.sequence_ontology_id = ot.ontology_term_id
    and t.parent_id = gf.na_feature_id
    and t.na_sequence_id = sns.na_sequence_id";

   my $workflowDataDir = $self->getWorkflowDataDir();


    if ($undo) {
      $self->runCmd(0, "rm -f $workflowDataDir/$outputFile");
    } else {
	if ($test) {
	    $self->runCmd(0,"echo test > $workflowDataDir/$outputFile");
	}
        $self->runCmd($test,"dumpSequencesFromTable.pl --outputFile $workflowDataDir/$outputFile --idSQL \"$sql\" --verbose");
    }
  }

1;

