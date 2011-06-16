package ApiCommonWorkflow::Main::WorkflowSteps::MakeEuPathUniProtLinkFile;

@ISA = (ApiCommonWorkflow::Main::Util::DownloadFileMaker);
use strict;
use ApiCommonWorkflow::Main::Util::DownloadFileMaker;


sub getDownloadFileCmd {
  my ($self, $downloadFileName, $test) = @_;


  my $dbrefExtDbRlsSpec = $self->getParamValue('dbrefExtDbRlsSpec');
  my $projectName = $self->getParamValue('projectName');

  my $arg = ($dbrefExtDbRlsSpec =~ /\|/)? 'dbrefExtDbSpec' : 'dbrefExtDbName';
  my $cmd = "dumpEuPath-UniProtLinks --dbrefExtDbSpec '$dbrefExtDbRlsSpec' --outfile $downloadFileName --projectName $projectName";
  return $cmd;
}



