package ApiCommonWorkflow::Main::WorkflowSteps::MakeGeneAliasesDownloadFile;

@ISA = (ApiCommonWorkflow::Main::Util::DownloadFileMaker);
use strict;
use ApiCommonWorkflow::Main::Util::DownloadFileMaker;


sub getDownloadFileCmd {
    my ($self, $downloadFileName, $test) = @_;

  my $genomeExtDbRlsSpec = $self->getParamValue('genomeExtDbRlsSpec');
  my $dbRefNAFeatureExtDbSpec = $self->getParamValue('dbRefNAFeatureExtDbSpec');

  my $cmd = "getGeneAliases --extDbSpec '$genomeExtDbRlsSpec' --outfile $downloadFileName --dbRefNAFeatureExtDbSpec '$dbRefNAFeatureExtDbSpec'";
  return $cmd;   
}

