package ApiCommonWorkflow::Main::WorkflowSteps::MakeTopLevelGeneFootprintFile;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test, $undo) = @_;

  my $outputFile = $self->getParamValue('outputFile');
  my $project = $self->getParamValue('project');
  my $genomeExtDbRlsSpec = $self->getParamValue('genomeExtDbRlsSpec');

  my $workflowDataDir = $self->getWorkflowDataDir();

  if ($undo) {
      $self->runCmd(0, "rm -f $workflowDataDir/$outputFile");
  } else {
      if ($test) {
	    $self->runCmd(0,"echo test > $workflowDataDir/$outputFile");
      }
      $self->runCmd($test,"makeGeneFootprintFile.pl --outputFile $workflowDataDir/$outputFile --project $project --genomeExtDbRlsSpec \'$genomeExtDbRlsSpec\' --verbose");
  }
}

1;
