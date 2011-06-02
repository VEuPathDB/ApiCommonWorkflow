package ApiCommonWorkflow::Main::WorkflowSteps::MakeOrfDownloadFile;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::DownloadFileMaker);
use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::DownloadFileMaker;


sub getExtraParams {
    return (
          'genomeExtDbRlsSpec',
#          'genomeVirtualSeqsExtDbRlsSpec',
          'soTermIdsOrNames',
	  'minOrfLength',
	);
}

sub getDownloadFileCmd {
    my ($self, $downloadFileName, $test) = @_;

  my @extDbRlsIds;
  push(@extDbRlsIds,$self->getExtDbRlsId($test, $self->getParamValue('genomeExtDbRlsSpec'))) if $self->getParamValue('genomeExtDbRlsSpec');
#  push(@extDbRlsIds,$self->getExtDbRlsId($test, $self->getParamValue('genomeVirtualSeqsExtDbRlsSpec'))) if $self->getParamValue('genomeVirtualSeqsExtDbRlsSpec'); FIX THIS see redmine #4306
  my $soIds =  $self->getSoIds($test, $self->getParamValue('soTermIdsOrNames')) if $self->getParamValue('soTermIdsOrNames');

  my $length = $self->getParamValue('minOrfLength');

  my $dbRlsIds = join(",", @extDbRlsIds);

   my $sql = <<"EOF";
    SELECT
       m.source_id
        ||' | organism='||
       replace(tn.name, ' ', '_')
        ||' | location='||
       fl.sequence_source_id
        ||':'||
       fl.start_min
        ||'-'||
       fl.end_max
        ||'('||
       decode(fl.is_reversed, 1, '-', '+')
        ||') | length='||
       taas.length as defline,
       taas.sequence
       FROM dots.miscellaneous m,
            dots.translatedaafeature taaf,
            dots.translatedaasequence taas,
            sres.taxonname tn,
            sres.sequenceontology so,
            apidb.featurelocation fl,
            dots.nasequence enas
      WHERE m.na_feature_id = taaf.na_feature_id
        AND taaf.aa_sequence_id = taas.aa_sequence_id
        AND m.na_feature_id = fl.na_feature_id
        AND fl.is_top_level = 1
        AND enas.na_sequence_id = fl.na_sequence_id 
        AND enas.taxon_id = tn.taxon_id
        AND tn.name_class = 'scientific name'
        AND m.sequence_ontology_id = so.sequence_ontology_id
        AND so.term_name = 'ORF'
        AND taas.length >= $length
        AND m.external_database_release_id in ($dbRlsIds)
EOF

  $sql .= " and enas.sequence_ontology_id in ($soIds)" if $soIds;
    my $cmd = <<"EOF";
      gusExtractSequences --outputFile $downloadFileName \\
      --idSQL \"$sql\" \\
      --verbose
EOF
    return $cmd;
}

