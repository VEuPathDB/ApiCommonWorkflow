package ApiCommonWorkflow::Main::WorkflowSteps::MakeMixedGenomicDownloadFile;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::DownloadFileMaker);
use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::DownloadFileMaker;

sub getDownloadFileCmd {
    my ($self, $downloadFileName, $test) = @_;

  # get parameters
#  my @genomeExtDbSpecList = split (/,/,$self->getParamValue('genomeExtDbSpecList'));
  my @genomeExtDbSpecList = "FIX THIS see redmine #4306";
  my $organismSource = $self->getParamValue('organismSource');

  my (@extDbRlsVers,@extDbNames);

  foreach ( @genomeExtDbSpecList ){
      my ($extDbName,$extDbRlsVer)=$self->getExtDbInfo($test,$_);
      push (@extDbNames,$extDbName);
      push (@extDbRlsVers,$extDbRlsVer);
  }

  my $extDbNameList = join(",", map{"'$_'"} @extDbNames);
  my $extDbRlsVerList = join(",",map{"'$_'"} @extDbRlsVers);
  my $soIds =  $self->getSoIds($test, $self->getParamValue('cellularLocationSoTerms'));

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
                ApidbTuning.SequenceAttributes sa
          WHERE ns.na_sequence_id = sa.na_sequence_id
            AND sa.database_name in ($extDbNameList) AND sa.database_version in ($extDbRlsVerList)
            AND sa.is_top_level = 1
            AND ns.sequence_ontology_id in ($soIds)";
  my $cmd = "gusExtractSequences --outputFile $downloadFileName  --idSQL \"$sql\" ";
  return $cmd;
}


