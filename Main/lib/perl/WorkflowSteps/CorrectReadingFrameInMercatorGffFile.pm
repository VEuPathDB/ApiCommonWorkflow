package ApiCommonWorkflow::Main::WorkflowSteps::CorrectReadingFrameInMercatorGffFile;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
    my ($self, $test, $undo) = @_;


    my $inputFastaFile = $self->getParamValue('inputFastaFile');
    my $inputGffFile = $self->getParamValue('inputGffFile');
    my $outputGffFile = $self->getParamValue('outputGffFile');

    my $workflowDataDir = $self->getWorkflowDataDir();


    my $cmd = "fixMercatorOffsetsInGFF.pl --f $workflowDataDir/$inputFastaFile --g $workflowDataDir/$inputGffFile --o $workflowDataDir/$outputGffFile";



    if ($undo) {
      $self->runCmd(0, "rm -fr $workflowDataDir/$outputGffFile");
    } else {
	if ($test) {
	    $self->runCmd(0,"echo hello > $workflowDataDir/$outputGffFile");
	}
        $self->runCmd($test, $cmd);
    }
}

1;
