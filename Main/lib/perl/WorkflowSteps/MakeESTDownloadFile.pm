package ApiCommonWorkflow::Main::WorkflowSteps::MakeESTDownloadFile;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WebsiteFileMaker);
use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WebsiteFileMaker;

sub getIsSpeciesLevel {
    return 1;
}

sub getSkipIfFile {
  my ($self) = @_;
  return $self->getParamValue('skipIfFile');
}

sub getWebsiteFileCmd { 
  my ($self, $downloadFileName, $test) = @_;

  my $organismAbbrev = $self->getParamValue('organismAbbrev');

  my $organismInfo = $self->getOrganismInfo($test, $organismAbbrev);
  my $taxonId = $organismInfo->getSpeciesTaxonId();
  my $taxonIdList = $organismInfo->getTaxonIdList($taxonId);


  my $soExtDbName = $self->getSharedConfig("sequenceOntologyExtDbName");

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
	sres.ontologyterm so, 
        sres.externaldatabase d,
        sres.externaldatabaserelease r
	WHERE t.taxon_id in ($taxonIdList)
	AND t.taxon_id = tn.taxon_id
	AND tn.name_class = 'scientific name'
	AND t.taxon_id = x.taxon_id
	AND x.sequence_ontology_id = so.ontology_term_id
	AND so.name = 'EST'
        AND so.external_database_release_id = r.external_database_release_id
        AND r.external_database_id = d.external_database_id
        AND d.name = '$soExtDbName'
EOF

    my $cmd = "gusExtractSequences --outputFile $downloadFileName  --allowEmptyOutput --idSQL \"$sql\" --verbose ";
    return $cmd;
}

1;
