package ApiCommonWorkflow::Main::WorkflowSteps::MakeNCBILinkoutsFiles_Nucleotide;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WebsiteFileMaker);
use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WebsiteFileMaker;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub getWebsiteFileCmd {
    my ($self, $downloadFileName, $test) = @_;

  # get parameters

  my $organismAbbrev = $self->getParamValue('organismAbbrev');

  my $downloadsite = $self->getParamValue('projectName');

  my $tuningTablePrefix = $self->getTuningTablePrefix($organismAbbrev, $test);

  my $cmd = "makeNCBILinkoutsFiles_Nucleotide.pl -output $downloadFileName -tuningTablePrefix $tuningTablePrefix --downloadsite $downloadsite";
  return $cmd;
}
