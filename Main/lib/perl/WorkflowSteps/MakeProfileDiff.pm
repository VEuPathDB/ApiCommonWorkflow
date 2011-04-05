package ApiCommonWorkflow::Main::WorkflowSteps::MakeProfileDiff;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
    my ($self, $test, $undo) = @_;

    my $maxFile = $self->getParamValue('maxInputFile');
    my $minFile = $self->getParamValue('minInputFile');
    my $outputFile = $self->getParamValue('outputFile');
    my $hasHeader = $self->getParamValue('hasHeader');

    my $workflowDataDir = $self->getWorkflowDataDir();
    my $stepDir = $self->getStepDir();

    my $cmd = "profileDifference.pl --minuend_file $workflowDataDir/$maxFile --subtrahend_file $workflowDataDir/$minFile --output_file $workflowDataDir/$outputFile";

    $cmd .= " --hasHeader" if ($hasHeader eq 'true');


    if ($undo) {
	$self->runCmd(0, "rm -f $workflowDataDir/outputFile");
    } else {
	if ($test) {
	    $self->testInputFile('maxInputFile', "$workflowDataDir/$maxFile");
	    $self->testInputFile('minInputFile', "$workflowDataDir/$minFile");
	    $self->runCmd(0,"echo test > $workflowDataDir/$maxFile");
            $self->runCmd(0,"echo test > $workflowDataDir/$minFile");
	}
	$self->runCmd($test, $cmd);
    }
}

sub getParamsDeclaration {
  return (
      'inputFile',
      'hasHeader',
      'outputFile',
      );
}

sub getConfigDeclaration {
  return (
	  # [name, default, description]
	 );
}


