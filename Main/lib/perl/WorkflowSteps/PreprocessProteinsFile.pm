package ApiCommonWorkflow::Main::WorkflowSteps::PreprocessProteinsFile;
@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;
use File::Basename;


sub run {
  my ($self, $test, $undo) = @_;

  my $inputProteinsFile = $self->getParamValue("inputProteinsFile");
  my $outputProteinsFile = $self->getParamValue("outputProteinsFile");
  my $nextflowWorkflow = $self->getParamValue("nextflowWorkflow");

  return unless($inputProteinsFile);


}

1;
