package ApiCommonWorkflow::Main::WorkflowSteps::MakeAnnotatedProteinsDownloadFile;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::DownloadFileMaker);
use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::DownloadFileMaker;

sub getExtraParams {
    return (
          'organismSource',
#          'genomeExtDbRlsSpecList',
	  'deprecated',
          'soTermIdsOrNames'
	);
}

sub getDownloadFileCmd {
    my ($self, $downloadFileName, $test) = @_;

  # get parameters
#  my @genomeExtDbSpecList = split(/,/,$self->getParamValue('genomeExtDbSpecList'));
  my @genomeExtDbSpecList = "FIUX THIS see redmine #4306";
  my $deprecated = ($self->getParamValue('deprecated') eq 'true') ? 1 :0;
  my $organismSource = $self->getParamValue('organismSource');

  my (@extDbRlsVers,@extDbNames);

  foreach ( @genomeExtDbSpecList ){
      my ($extDbName,$extDbRlsVer)=$self->getExtDbInfo($test,$_);
      push (@extDbNames,$extDbName);
      push (@extDbRlsVers,$extDbRlsVer);

  }

  my $extDbNameList = join(",", map{"'$_'"} @extDbNames);
  my $extDbRlsVerList = join(",",map{"'$_'"} @extDbRlsVers);
  my $soIds =  $self->getSoIds($test, $self->getParamValue('soTermIdsOrNames')) if $self->getParamValue('soTermIdsOrNames');

  my $sql = "SELECT '$organismSource'
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
            (fl.start_min + taaf.translation_start - 1)
                ||'-'||
            (fl.end_max - (snas.length - taaf.translation_stop))
                ||'('||
            decode(fl.is_reversed, 1, '-', '+')
                ||') | length='||
            taas.length
            as defline,
            taas.sequence
           FROM apidb.featurelocation fl,
                apidb.geneattributes gf,
                dots.transcript t,
                dots.splicednasequence snas,
                dots.translatedaafeature taaf,
                dots.translatedaasequence taas,
                dots.nasequence ns
      WHERE gf.na_feature_id = t.parent_id
        AND ns.na_sequence_id = fl.na_sequence_id
        AND t.na_sequence_id = snas.na_sequence_id
        AND gf.na_feature_id = fl.na_feature_id
        AND gf.so_term_name != 'repeat_region'
        AND gf.so_term_name = 'protein_coding'
        AND gf.external_db_name in ($extDbNameList) AND gf.external_db_version in ($extDbRlsVerList)
        AND t.na_feature_id = taaf.na_feature_id
        AND taaf.aa_sequence_id = taas.aa_sequence_id
        AND fl.is_top_level = 1
        AND gf.is_deprecated = $deprecated";


  $sql .= " and ns.sequence_ontology_id in ($soIds)" if $soIds;
  my $cmd = " gusExtractSequences --outputFile $downloadFileName  --idSQL \"$sql\"";
    return $cmd;
}

1;
