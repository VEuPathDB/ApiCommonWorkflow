package ApiCommonWorkflow::Main::WorkflowSteps::DumpPseudogenes;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;
use File::Basename;

sub run {
  my ($self, $test, $undo) = @_;

  my $outputFile = $self->getParamValue('outputFile');
  my $organismAbbrev = $self->getParamValue('organismAbbrev');
  my $gusConfigFile = $self->getGusConfigFile();
  my $workflowDataDir = $self->getWorkflowDataDir();

  my $dir = dirname($outputFile);
  if ($undo) {
      $self->runCmd(0, "rm -f $workflowDataDir/$outputFile");
  } else {
      if ($test) {
	    $self->runCmd(0,"echo test > $workflowDataDir/$outputFile");
      }
      $self->runCmd($test,"dumpPseudogenes.pl --outputFile $workflowDataDir/$outputFile --organismAbbrev $organismAbbrev --gusConfigFile $gusConfigFile");
  }
}

1;
