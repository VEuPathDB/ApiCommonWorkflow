package ApiCommonWorkflow::Main::WorkflowSteps::MakeESTDownloadFile;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::DownloadFileMaker);
use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::DownloadFileMaker;

sub getDownloadFileCmd {
    my ($self, $downloadFileName, $test) = @_;

    my $organismAbbrev = $self->getParamValue('organismAbbrev');

    my $speciesTaxonId = $self->getOrganismInfo($test, $organismAbbrev)->getSpeciesNcbiTaxonId();
    my $taxonIdList = $self->getTaxonIdList($test, $speciesTaxonId, 1);

    my $sql = <<"EOF";
    SELECT x.source_id
	||' | organism='||
	replace(tn.name, ' ', '_')
	||' | length='||
	x.length as defline,
	x.sequence
	FROM dots.externalnasequence x,
	sres.taxonname tn,
	sres.taxon t,
	sres.sequenceontology so
	WHERE t.taxon_id in ($taxonIdList)
	AND t.taxon_id = tn.taxon_id
	AND tn.name_class = 'scientific name'
	AND t.taxon_id = x.taxon_id
	AND x.sequence_ontology_id = so.sequence_ontology_id
	AND so.term_name = 'EST'
EOF

    my $cmd = "gusExtractSequences --outputFile $downloadFileName  --idSQL \"$sql\"";
    return $cmd;
}

1;
