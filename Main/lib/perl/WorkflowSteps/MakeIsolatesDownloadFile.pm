package ApiCommonWorkflow::Main::WorkflowSteps::MakeIsolatesDownloadFile;

## NOTE: this stepclass is specifically extracting the isolates from GenBank
##       If we want another data source, we'll need to extend this step class and add an externaldb param.

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::DownloadFileMaker);
use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::DownloadFileMaker;

sub getIsSpeciesLevel {
    return 1;
}

sub getDownloadFileCmd { 
  my ($self, $downloadFileName, $test) = @_;

  my $organismAbbrev = $self->getParamValue('organismAbbrev');
  my $organismInfo = $self->getOrganismInfo($test, $organismAbbrev);
  my $taxonId = $organismInfo->getSpeciesTaxonId();
  my $taxonIdList = $organismInfo->getTaxonIdList($taxonId);

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
             dots.isolatesource i
        Where tn.taxon_id in ($taxonIdList)
            AND enas.taxon_id = tn.taxon_id
            AND tn.name_class = 'scientific name'
            AND enas.external_database_release_id = edr.external_database_release_id
            AND edr.external_database_id = ed.external_database_id
            AND edr.data_type = 'isolates'
            AND edr.data_subtype = 'Sequencing Typed'
            AND enas.na_sequence_id = i.na_sequence_id
            AND so.sequence_ontology_id = enas.sequence_ontology_id
EOF

    my $cmd = "gusExtractSequences --outputFile $downloadFileName  --allowEmptyOutput --idSQL \"$sql\"";
    return $cmd;
}

1;
