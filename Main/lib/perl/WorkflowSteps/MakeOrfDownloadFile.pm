package ApiCommonWorkflow::Main::WorkflowSteps::MakeOrfDownloadFile;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);
use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;


sub run {
  my ($self, $test, $undo) = @_;

  # get parameters
  my $outputFile = $self->getParamValue('outputFile');
  my $descripFile= $self->getParamValue('descripFile');
  my $descripString= $self->getParamValue('descripString');

  my @extDbRlsIds;
  push(@extDbRlsIds,$self->getExtDbRlsId($test, $self->getParamValue('genomeExtDbRlsSpec'))) if $self->getParamValue('genomeExtDbRlsSpec');
  push(@extDbRlsIds,$self->getExtDbRlsId($test, $self->getParamValue('genomeVirtualSeqsExtDbRlsSpec'))) if $self->getParamValue('genomeVirtualSeqsExtDbRlsSpec');
  my $soIds =  $self->getSoIds($test, $self->getParamValue('soTermIdsOrNames')) if $self->getParamValue('soTermIdsOrNames');

  my $length = $self->getParamValue('minOrfLength');

  my $apiSiteFilesDir = $self->getSharedConfig('apiSiteFilesDir');

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
      gusExtractSequences --outputFile $apiSiteFilesDir/$outputFile \\
      --idSQL \"$sql\" \\
      --verbose
EOF

  my $cmdDec = "writeDownloadFileDecripWithDescripString --descripString '$descripString' --outputFile $apiSiteFilesDir/$descripFile";


  if ($undo) {
    $self->runCmd(0, "rm -f $apiSiteFilesDir/$outputFile");
    $self->runCmd(0, "rm -f $apiSiteFilesDir/$descripFile");
  } else {
      if ($test) {
	  $self->runCmd(0,"echo test > $apiSiteFilesDir/$outputFile");
      }else{
	  $self->runCmd($test,$cmd);
	  $self->runCmd($test, $cmdDec);
      }
  }
}

sub getParamsDeclaration {
  return (
          'outputFile',
          'genomeExtDbRlsSpec',
          'genomeVirtualSeqsExtDbRlsSpec',
          'soTermIdsOrNames'
         );
}

sub getConfigDeclaration {
  return (
         # [name, default, description]
         # ['', '', ''],
         );
}

