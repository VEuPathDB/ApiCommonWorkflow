 package ApiCommonWorkflow::Main::WorkflowSteps::FormatNcbiBlastFile;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test, $undo) = @_;

  my $sequencesFile = $self->getParamValue('sequencesFile');
  my $formatterArgs = $self->getParamValue('formatterArgs');

  my $ncbiBlastPath = $self->getConfig('ncbiBlastPath');

  my $workflowDataDir = $self->getWorkflowDataDir();

  my $fileToFormat = "$workflowDataDir/$sequencesFile";

  if ($undo) {
    $self->runCmd(0, "rm -f ${fileToFormat}.p*");
  } else {
      if ($test) {
	  $self->runCmd(0,"echo test > $fileToFormat.pin");
      }
      $self->runCmd($test,"$ncbiBlastPath/formatdb -i $fileToFormat -p $formatterArgs");

  }
}

1;

