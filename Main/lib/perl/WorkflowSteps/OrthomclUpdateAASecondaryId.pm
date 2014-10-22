package ApiCommonWorkflow::Main::WorkflowSteps::OrthomclUpdateAASecondaryId;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test, $undo) = @_;

  my $cmd = "updateAASecondaryId";


  if ($undo) {
  } else {  
      if ($test) {
      }
      $self->runCmd($test,$cmd);
  }
}

1;
