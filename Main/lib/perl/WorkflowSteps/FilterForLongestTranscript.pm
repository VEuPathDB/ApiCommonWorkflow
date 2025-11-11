package ApiCommonWorkflow::Main::WorkflowSteps::FilterForLongestTranscript;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;
use File::Basename;

sub run {
  my ($self, $test, $undo) = @_;

  my $workflowDataDir = $self->getWorkflowDataDir();
  my $fastaDir = $self->getParamValue('fastaDir');
  my $fastaDirFullPath = "$workflowDataDir/$fastaDir";

  my $cmd = "filterForLongestTranscript --fastaDir $fastaDirfullPath";

  if ($undo) {
      next;
  }else {
    if ($test){
        next;
    }
    $self->runCmd($test, $cmd);
  }

}

1;
