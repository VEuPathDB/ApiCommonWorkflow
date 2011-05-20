package ApiCommonWorkflow::Main::WorkflowSteps::MakeAnnotatedCDSDownloadFile;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);
use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;


sub run {
  my ($self, $test, $undo) = @_;

  # get parameters
  my $outputFile = $self->getParamValue('outputFile');
  my $organismSource = $self->getParamValue('organismSource');
  my $deprecated = ($self->getParamValue('deprecated') eq 'true') ? 1 :0;
  my $descripFile= $self->getParamValue('descripFile');
  my $descripString = $self->getParamValue('descripString');

  my (@dbnames,@dbvers);
  my ($name,$ver) = $self->getExtDbInfo($test, $self->getParamValue('genomeExtDbRlsSpec')) if $self->getParamValue('genomeExtDbRlsSpec');
  push (@dbnames,$name);
  push (@dbvers,$ver);
  ($name,$ver) = $self->getExtDbInfo($test, $self->getParamValue('genomeVirtualSeqsExtDbRlsSpec')) if $self->getParamValue('genomeVirtualSeqsExtDbRlsSpec');
  push (@dbnames,$name);
  push (@dbvers,$ver);
  my $names = join (",", map{"'$_'"} @dbnames);
  my $vers = join (",", map{"'$_'"} @dbvers);
  my $soIds =  $self->getSoIds($test, $self->getParamValue('soTermIdsOrNames')) if $self->getParamValue('soTermIdsOrNames');

  my $deprecatedGene;

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
           FROM apidb.featurelocation fl,
                apidb.geneattributes gf,
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
        AND gf.external_db_name in ($names) 
        AND gf.external_db_version in ($vers)
        AND t.na_feature_id = taaf.na_feature_id
        AND fl.is_top_level = 1
        AND gf.is_deprecated = $deprecated
EOF

  $sql .= " and ns.sequence_ontology_id in ($soIds)" if $soIds;
  my $cmd = "gusExtractSequences --outputFile $outputFile  --idSQL \"$sql\"  --verbose";
  my $cmdDec = "writeDownloadFileDecripWithDescripString --descripString '$descripString' --outputFile $descripFile";



  if ($undo) {
    #$self->runCmd(0, "rm -f $outputFile");
    #$self->runCmd(0, "rm -f $descripFile");
  } else {
      if ($test) {
	  $self->runCmd(0,"echo test > $outputFile");
      }else{
	  $self->runCmd($test,$cmd);
	  $self->runCmd($test, $cmdDec);
      }
  }
}


sub getParamsDeclaration {
  return (
          'outputFile',
          'organismSource',
          'genomeExtDbRlsSpec',
          'genomeVirtualSeqsExtDbRlsSpec',
	  'deprecated',
          'soTermIdsOrNames'
         );
}

sub getConfigDeclaration {
  return (
         # [name, default, description]
         # ['', '', ''],
         );
}

