package ApiCommonWorkflow::Main::WorkflowSteps::MakeEuPathUniProtLinkFile;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WebsiteFileMaker);
use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WebsiteFileMaker;


sub getWebsiteFileCmd {
  my ($self, $downloadFileName, $test) = @_;


  my $dbrefExtDbName = $self->getParamValue('dbrefExtDbName');
  my $projectName = $self->getParamValue('projectName');

  my $genomeExtDbRlsSpec = $self->getParamValue('genomeExtDbRlsSpec');

  my $gusConfigFile = $self->getGusConfigFile();

  my $cmd = "dumpEuPath-UniProtLinks --genomeExtDbRlsSpec $genomeExtDbRlsSpec --dbrefExtDbName $dbrefExtDbName --outfile $downloadFileName --projectName $projectName --gusConfigFile $gusConfigFile";
  return $cmd;
}



