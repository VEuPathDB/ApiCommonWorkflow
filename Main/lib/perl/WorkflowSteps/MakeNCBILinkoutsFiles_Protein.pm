package ApiCommonWorkflow::Main::WorkflowSteps::MakeNCBILinkoutsFiles;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WebsiteFileMaker);
use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WebsiteFileMaker;


sub getWebsiteFileCmd {
  my ($self, $downloadFileName, $test) = @_;


  my $organismAbbrev = $self->getParamValue('organismAbbrev');
  
  my $cmd = "makeNCBILinkoutsFiles.pl --output $downloadFileName --organismAbbrev $organismAbbrev ";
  
  return $cmd;
}



