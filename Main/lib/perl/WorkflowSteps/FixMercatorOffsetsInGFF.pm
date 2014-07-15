package ApiCommonWorkflow::Main::WorkflowSteps::FixMercatorOffsetsInGFF;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
    my ($self, $test, $undo) = @_;

    my $inputFile = $self->getParamValue('inputFile');
    my $fsaFile = $self->getParamValue('fsaFile');
    my $outputFile = $self->getParamValue('outputFile');

    my $workflowDataDir = $self->getWorkflowDataDir();


    my $args = "--f $workflowDataDir/$fsaFile --g $workflowDataDir/$inputFile --o $workflowDataDir/$outputFile";

    if ($undo) {
      $self->runCmd(0, "rm -f $workflowDataDir/$outputFile");
    } else {
      $self->testInputFile('fsaFile', "$workflowDataDir/$fsaFile");
      $self->testInputFile('inputFile', "$workflowDataDir/$inputFile");
      if ($test){
        $self->runCmd(0,"echo test > $workflowDataDir/$outputFile");
      }
      $self->runCmd($test,"fixMercatorOffsetsInGFF.pl $args");
    }
}

1;
