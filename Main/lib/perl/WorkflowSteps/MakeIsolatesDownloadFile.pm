package ApiCommonWorkflow::Main::WorkflowSteps::MakeIsolatesDownloadFile;

## NOTE: this stepclass is specifically extracting the isolates from GenBank
##       If we want another data source, we'll need to extend this step class and add an externaldb param.

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WebsiteFileMaker);
use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WebsiteFileMaker;

sub getIsFamilyLevel {
    return 1;
}

sub getSkipIfFile {
  my ($self) = @_;
  return $self->getParamValue('skipIfFile');
}


sub getWebsiteFileCmd {
  my ($self, $downloadFileName, $test) = @_;

  # we load isolates using the family representative's taxon id, so use that to extract
  # only the family rep calls this step class, so we can just use our org abbrev.
  my $organismAbbrev = $self->getParamValue('organismAbbrev');
  my $organismInfo = $self->getOrganismInfo($test, $organismAbbrev);
  my $taxonId = $organismInfo->getTaxonId();

  my $sql = <<"EOF";
        SELECT
        enas.source_id
        ||' | organism='|| 
        replace(tn.name, ' ', '_')
        ||' | description='||
        decode (enas.description,null,'Not Available',enas.description)
        ||' | length='||
        enas.length
        as defline,
        enas.sequence
        From dots.ExternalNASequence enas,
             SRES.sequenceontology so,
             sres.taxonname tn,
             sres.externaldatabase ed,
             sres.externaldatabaserelease edr,
             apidb.datasource ds,
             dots.isolatesource i
        Where tn.taxon_id = $taxonId
            AND enas.taxon_id = tn.taxon_id
            AND tn.name_class = 'scientific name'
            AND enas.external_database_release_id = edr.external_database_release_id
            AND edr.external_database_id = ed.external_database_id
            AND ed.name = ds.name
            AND ds.subtype = 'sequencing_typed'
            AND enas.na_sequence_id = i.na_sequence_id
            AND so.sequence_ontology_id = enas.sequence_ontology_id
EOF

  my $cmd = "gusExtractSequences --outputFile $downloadFileName  --allowEmptyOutput --idSQL \"$sql\"";
  return $cmd;
}

1;
