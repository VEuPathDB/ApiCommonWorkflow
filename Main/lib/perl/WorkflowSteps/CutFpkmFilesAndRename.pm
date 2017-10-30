package ApiCommonWorkflow::Main::WorkflowSteps::CutFpkmFilesAndRename;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;


sub run {
  my ($self, $test, $undo) = @_;

  my $inputDirectory = $self->getParamValue('inputDirectory');
  my $outputDirectory = $self->getParamValue('outputDirectory');
  my $sampleName = $self->getParamValue('sampleName');

  my $workflowDataDir = $self->getWorkflowDataDir();

  my $cmd = "renameRnaseqIntensityFiles.pl --inputDirectory $workflowDataDir/$inputDirectory --outputDirectory $workflowDataDir/$outputDirectory --sampleName '$sampleName'";

  if ($undo) {
    $self->runCmd(0, "rm -f $workflowDataDir/$outputDirectory/$sampleName*.counts");
    $self->runCmd(0, "rm -f $workflowDataDir/$outputDirectory/$sampleName*.fpkm");
  } else {
      if ($test) {
	  $self->runCmd(0,"echo test > $workflowDataDir/$outputDirectory/$sampleName");
      }
    $self->runCmd($test,$cmd);

  }
}

1;
