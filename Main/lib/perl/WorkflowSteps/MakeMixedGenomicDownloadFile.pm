package ApiCommonWorkflow::Main::WorkflowSteps::MakeMixedGenomicDownloadFile;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);
use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test, $undo) = @_;

  # get parameters
  my @genomeExtDbSpecList = split (/,/,$self->getParamValue('genomeExtDbSpecList'));
  my $outputFile = $self->getParamValue('outputFile');
  my $organismSource = $self->getParamValue('organismSource');
  my $descripFile= $self->getParamValue('descripFile');
  my $descripString= $self->getParamValue('descripString');

  my (@extDbRlsVers,@extDbNames);

  foreach ( @genomeExtDbSpecList ){
      my ($extDbName,$extDbRlsVer)=$self->getExtDbInfo($test,$_);
      push (@extDbNames,$extDbName);
      push (@extDbRlsVers,$extDbRlsVer);
  }

  my $extDbNameList = join(",", map{"'$_'"} @extDbNames);
  my $extDbRlsVerList = join(",",map{"'$_'"} @extDbRlsVers);
  my $soIds =  $self->getSoIds($test, $self->getParamValue('soTermIdsOrNames')) if $self->getParamValue('soTermIdsOrNames');

  my $sql = " SELECT '$organismSource'
                ||'|'||
               sa.source_id
                ||' | organism='||
               replace(sa.organism, ' ', '_')
                ||' | version='||
               sa.database_version
                ||' | length=' ||
               sa.length
               as defline,
               ns.sequence
           FROM dots.nasequence ns,
                apidb.sequenceattributes sa
          WHERE ns.na_sequence_id = sa.na_sequence_id
            AND sa.database_name in ($extDbNameList) AND sa.database_version in ($extDbRlsVerList)
            AND sa.is_top_level = 1";

  $sql .= " and ns.sequence_ontology_id in ($soIds)" if $soIds;
  my $cmd = "gusExtractSequences --outputFile $outputFile  --idSQL \"$sql\" ";
  my $cmdDec = "writeDownloadFileDecripWithDescripString --descripString '$descripString' --outputFile $descripFile";


  
  if($undo){
    $self->runCmd(0, "rm -f $outputFile");
    $self->runCmd(0, "rm -f $descripFile");
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


