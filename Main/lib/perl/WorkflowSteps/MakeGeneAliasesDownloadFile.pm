package ApiCommonWorkflow::Main::WorkflowSteps::MakeGeneAliasesDownloadFile;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WebsiteFileMaker);
use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WebsiteFileMaker;


sub getWebsiteFileCmd {
    my ($self, $downloadFileName, $test) = @_;

  my $genomeExtDbRlsSpec = $self->getParamValue('genomeExtDbRlsSpec');
my $gusConfigFile = $self->getGusConfigFile();

  my $cmd = "getGeneAliases --genomeExtDbSpec '$genomeExtDbRlsSpec' --outfile $downloadFileName  --gusConfigFile $gusConfigFile";

  return $cmd;   
}

