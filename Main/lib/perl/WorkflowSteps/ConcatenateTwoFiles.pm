package ApiCommonWorkflow::Main::WorkflowSteps::ConcatenateTwoFiles;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;


sub run {
    my ($self, $test, $undo) = @_;

    my $in1 = $self->getParamValue('inputFile1');
    my $in2 = $self->getParamValue('inputFile2');
    my $out = $self->getParamValue('outputFile');

    my $workflowDataDir = $self->getWorkflowDataDir();
    my $stepDir = $self->getStepDir();

    my $cmd = "cat $in1 $in2 > $out";

    if ($undo) {
	$self->runCmd(0, "rm -f $workflowDataDir/$out");
    } else {
      $self->testInputFile('inputFile1', "$workflowDataDir/$in1");
      $self->testInputFile('inputFile2', "$workflowDataDir/$in2");
            
	if ($test) {
	    $self->runCmd(0,"echo test > $workflowDataDir/$out");
	}
      $self->runCmd($test, $cmd);
    }
}

1;

