package ApiCommonWorkflow::Main::WorkflowSteps::MakeAnnotatedProteinsDownloadFile;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);
use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test, $undo) = @_;

  # get parameters
  my @genomeExtDbSpecList = split(/,/,$self->getParamValue('genomeExtDbSpecList'));
  my $outputFile = $self->getParamValue('outputFile');
  my $deprecated = ($self->getParamValue('deprecated') eq 'true') ? 1 :0;
  my $descripFile= $self->getParamValue('descripFile');
  my $descripString= $self->getParamValue('descripString');
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
           FROM apidbtuning.featurelocation fl,
                apidbtuning.geneattributes gf,
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
  my $cmd = " gusExtractSequences --outputFile $outputFile  --idSQL \"$sql\"";
  my $cmdDec = "writeDownloadFileDecripWithDescripString --descripString '$descripString' --outputFile $descripFile";


  
  if ($undo) {
    #$self->runCmd(0, "rm -f $outputFile");
    #$self->runCmd(0, "rm -f $descripFile");
  }else{
      if ($test) {
	  $self->runCmd(0, "echo test > $outputFile");
      }else{
	  $self->runCmd($test, $cmd);
	  $self->runCmd($test, $cmdDec);
      }
  }

}




sub getParamsDeclaration {
  return (
          'outputFile',
          'extDbName',
          'extDbRls',
          'deprecated',
	  'organismSource',
          'soTermIdsOrNames'
         );
}

sub getConfigDeclaration {
  return (
         # [name, default, description]
         # ['', '', ''],
         );
}
