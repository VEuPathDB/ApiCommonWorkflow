package ApiCommonWorkflow::Main::WorkflowSteps::MakeAnnotatedTranscriptsDownloadFile;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::DownloadFileMaker);
use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::DownloadFileMaker;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;


sub getDownloadFileCmd {
  my ($self, $downloadFileName, $test) = @_;

  # get parameters
  my $organismAbbrev = $self->getParamValue('organismAbbrev');
  my $organismSource = $self->getParamValue('organismSource');

  my $ncbiTaxonId = $self->getOrganismInfo($test, $organismAbbrev)->getNcbiTaxonId();

  my $tuningTablePrefix = $self->getTuningTablePrefix($organismAbbrev, $test);

  my $sql = <<"EOF";
     SELECT '$organismSource'
                ||'|'||
            gf.source_id
                || decode(gf.is_deprecated, 1, ' | deprecated=true', '')
                ||' | organism='||
            replace( gf.organism, ' ', '_')
                ||' | product='||
            product_name.product
                ||' | location='||
            fl.sequence_source_id
                ||':'||
            fl.start_min
                ||'-'||
            fl.end_max
                ||'('||
            decode(fl.is_reversed, 1, '-', '+')
                ||') | length='||
            snas.length || ' | sequence_SO=' || soseq.term_name
                || ' | SO=' || gf.so_term_name
            as defline,
            snas.sequence
           FROM ApidbTuning.${tuningTablePrefix}GeneAttributes gf,
                dots.transcript t,
                dots.splicednasequence snas,
                ApidbTuning.${tuningTablePrefix}FeatureLocation fl,
                dots.nasequence ns,
                sres.sequenceontology soseq,
                (select gf.na_feature_id,
                        substr(coalesce(preferred_product.product, any_product.product, gf.product, 'unspecified product'),
                               1, 300)
                        || case
                             when (coalesce(preferred_name.name, any_name.name) is not null)
                             then ' (' || coalesce(preferred_name.name, any_name.name) || ')'
                             else ''
                            end
                        as product
                 from dots.GeneFeature gf,
                      (select na_feature_id, max(product) as product
                       from apidb.GeneFeatureProduct
                       where is_preferred = 1
                       group by na_feature_id
                      ) preferred_product,
                      (select na_feature_id, max(product) as product
                       from apidb.GeneFeatureProduct
                       group by na_feature_id
                      ) any_product,
                      (select na_feature_id, max(name) as name
                       from apidb.GeneFeatureName
                       where is_preferred = 1
                       group by na_feature_id
                      ) preferred_name,
                      (select na_feature_id, max(name) as name
                       from apidb.GeneFeatureName
                       group by na_feature_id
                      ) any_name
                 where gf.na_feature_id = preferred_product.na_feature_id(+)
                   and gf.na_feature_id = any_product.na_feature_id(+)
                   and gf.na_feature_id = preferred_name.na_feature_id(+)
                   and gf.na_feature_id = any_name.na_feature_id(+)
                ) product_name
      WHERE gf.na_feature_id = t.parent_id
        AND ns.na_sequence_id = fl.na_sequence_id
        AND t.na_sequence_id = snas.na_sequence_id
        AND gf.na_feature_id = fl.na_feature_id
        AND gf.so_term_name != 'repeat_region'
        AND gf.ncbi_tax_id = $ncbiTaxonId
        AND fl.is_top_level = 1
        AND ns.sequence_ontology_id = soseq.sequence_ontology_id
        and gf.na_feature_id = product_name.na_feature_id
EOF

  my $cmd = "gusExtractSequences --outputFile $downloadFileName  --idSQL \"$sql\" --verbose";
}

