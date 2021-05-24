package ApiCommonWorkflow::Main::WorkflowSteps::MakeTopLevelGeneFootprintFile;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;
use File::Basename;

sub run {
  my ($self, $test, $undo) = @_;

  my $outputFile = $self->getParamValue('outputFile');
  my $project = $self->getParamValue('project');
  my $genomeExtDbRlsSpec = $self->getParamValue('genomeExtDbRlsSpec');

  my $workflowDataDir = $self->getWorkflowDataDir();


  my $dir = dirname($outputFile);
  if ($undo) {
      $self->runCmd(0, "rm -f $workflowDataDir/$outputFile");
      $self->runCmd(0, "rm -f $workflowDataDir/$dir/maxIntronLen");
  } else {
      if ($test) {
	    $self->runCmd(0,"echo test > $workflowDataDir/$outputFile");
        $self->runCmd(0, "echo test > $workflowDataDir/$dir/maxIntronLen");
      }
      $self->runCmd($test,"makeGeneFootprintFile.pl --outputFile $workflowDataDir/$outputFile --project $project --genomeExtDbRlsSpec \'$genomeExtDbRlsSpec\' --verbose");
  }
}

1;
