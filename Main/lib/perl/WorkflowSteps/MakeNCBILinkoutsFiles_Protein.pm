package ApiCommonWorkflow::Main::WorkflowSteps::MakeNCBILinkoutsFiles_Protein;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WebsiteFileMaker);
use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WebsiteFileMaker;


sub getWebsiteFileCmd {
  my ($self, $downloadFileName, $test) = @_;


  my $organismAbbrev = $self->getParamValue('organismAbbrev');
  my $gusConfigFile = $self->getGusConfigFile();

  my $cmd = "makeNCBILinkoutsFiles_Protein.pl --output $downloadFileName --organismAbbrev $organismAbbrev --gusConfigFile $gusConfigFile";
  
  return $cmd;
}



