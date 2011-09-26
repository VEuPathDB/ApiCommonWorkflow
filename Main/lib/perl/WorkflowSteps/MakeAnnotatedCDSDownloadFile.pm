package ApiCommonWorkflow::Main::WorkflowSteps::MakeAnnotatedCDSDownloadFile;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::DownloadFileMaker);
use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::DownloadFileMaker;


sub getDownloadFileCmd {
    my ($self, $downloadFileName, $test) = @_;

    my $organismSource = $self->getParamValue('organismSource');
    my $deprecated = ($self->getParamValue('isDeprecatedGenes') eq 'true') ? 1 :0;

    my $organismAbbrev = $self->getParamValue('organismAbbrev');
    my $ncbiTaxonId = $self->getOrganismInfo($organismAbbrev)->getNcbiTaxonId();
    $downloadFileName =~ s/\.fasta/-deprecatedGenes.fasta/ if $deprecated;

  my $soIds =  $self->getSoIds($test, $self->getParamValue('soTermIdsOrNames')) if $self->getParamValue('soTermIdsOrNames');

    my $sql = <<"EOF";
     SELECT '$organismSource'
                ||'|'||
            gf.source_id
                 || decode(gf.is_deprecated, 1, ' | deprecated=true', '')
                 ||' | organism='||
           replace( gf.organism, ' ', '_')
                ||' | product='||
            gf.product
                ||' | location='||
            fl.sequence_source_id
                ||':'||
            least(gf.coding_start,gf.coding_end)
                ||'-'||
	    greatest(gf.coding_start,gf.coding_end)
                ||'('||
            decode(fl.is_reversed, 1, '-', '+')
                ||') | length='||
            (abs(gf.coding_start - gf.coding_end) + 1)
            as defline,
           SUBSTR(snas.sequence,
                  taaf.translation_start,
                  taaf.translation_stop - taaf.translation_start + 1)
           FROM ApidbTuning.FeatureLocation fl,
                ApidbTuning.GeneAttributes gf,
                dots.transcript t,
                dots.splicednasequence snas,
                dots.translatedaafeature taaf,
                dots.nasequence ns
      WHERE gf.na_feature_id = t.parent_id
        AND fl.na_sequence_id = ns.na_sequence_id
        AND t.na_sequence_id = snas.na_sequence_id
        AND gf.na_feature_id = fl.na_feature_id
        AND gf.so_term_name != 'repeat_region'
        AND gf.so_term_name = 'protein_coding'
        AND gf.ncbi_tax_id = $ncbiTaxonId 
        AND t.na_feature_id = taaf.na_feature_id
        AND fl.is_top_level = 1
        AND gf.is_deprecated = $deprecated
EOF

	$sql .= " and ns.sequence_ontology_id in ($soIds)" if $soIds;
    my $cmd = "gusExtractSequences --outputFile $downloadFileName  --idSQL \"$sql\"  --verbose";
    return $cmd;
}
1;
