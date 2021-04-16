package ApiCommonWorkflow::Main::WorkflowSteps::CheckForCompletedFile;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);
use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test, $undo) = @_;

  my $completedFile = $self->getParamValue('completedFile');
  my $waitSeconds = $self->getParamValue('waitSeconds');

  if ($undo) {
  } else {
      while () {
	  last if (-e $completedFile);
	  sleep($waitSeconds);
      }
      open (FH,$completedFile);
      my $timeStamp = localtime((stat(FH))[9]);
      close FH;
      $self->log("File '$completedFile' was last modified $timeStamp");
  }
}

1;
