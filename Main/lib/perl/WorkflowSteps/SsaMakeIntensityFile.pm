package ApiCommonWorkflow::Main::WorkflowSteps::SsaMakeIntensityFile;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
    my ($self, $test, $undo) = @_;

    my $inputCoverageFile = $self->getParamValue('inputCoverageFile');
    my $inputGeneModelFile = $self->getParamValue('inputGeneModelFile');
    my $outputIntensityFile = $self->getParamValue('outputIntensityFile');

    my $workflowDataDir = $self->getWorkflowDataDir();
    my $stepDir = $self->getStepDir();

    my $cmd = "quantify_one_sample.pl $workflowDataDir/$inputCoverangeFile $workflowDataDir/$inputGeneModelFile > $workflowDataDir/$outputIntensityFile";

    if ($undo) {
	$self->runCmd(0, "rm -f $workflowDataDir/$outputIntensityFile");
    } else {
	if ($test) {
	    $self->testInputFile('inputCoverageFile', "$workflowDataDir/$inputCoverageFile");
	    $self->testInputFile('inputGeneModelFile', "$workflowDataDir/$inputGeneModelFile");
	    $self->runCmd(0,"echo test > $workflowDataDir/$outputIntensityFile");
	}
	$self->runCmd($test, $cmd);
    }
}

sub getParamsDeclaration {
  return (
      'inputGeneModelFile',
      'inputCoverageFile',
      'outputIntensityFile',
      );
}

sub getConfigDeclaration {
  return (
	  # [name, default, description]
	 );
}


