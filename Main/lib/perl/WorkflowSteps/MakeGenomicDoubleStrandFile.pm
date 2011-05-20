package ApiCommonWorkflow::Main::WorkflowSteps::MakeGenomicDoubleStrandFile;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::DownloadFileMaker);
use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::DownloadFileMaker;

sub getExtraParams {
    return (
          'organismSource',
          'genomeExtDbRlsSpecList',
          'soTermIdsOrNames'
	);
}

sub getDownloadFileCmd {
    my ($self, $downloadFileName) = @_;

  # get parameters
  my @genomeExtDbSpecList = split (/,/,$self->getParamValue('genomeExtDbSpecList'));
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

  my $sql = " SELECT '$organismSource'
                ||'|'||
               sa.source_id
                ||' | strand=(+)'
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
  my $cmd = "gusExtractSequences --outputFile $outputFile  --idSQL \"$sql\"  --posStrand '\\+' --negStrand '-' ";
  return $cmd;
}


