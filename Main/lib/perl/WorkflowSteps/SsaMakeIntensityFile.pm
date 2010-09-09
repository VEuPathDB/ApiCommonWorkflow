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

    my ($uniqueUnNorm,$nuUnNorm) = split(',',$inputCoverageFile);

    my $cmd1 = "cat $workflowDataDir/$uniqueUnNorm $workflowDataDir/$nuUnNorm > $stepDir/unNormAll.cov";

    my $tempOutputFile="$workflowDataDir/$outputIntensityFile"."ori";

    my $cmd2 = "quantify_one_sample.pl $stepDir/unNormAll.cov $workflowDataDir/$inputGeneModelFile > $tempOutputFile";

    my $cmd3 = "featurequant2geneprofiles.pl $workflowDataDir/$outputIntensityFile.ori -genes > $workflowDataDir/$outputIntensityFile";

    if ($undo) {
	$self->runCmd(0, "rm -f $workflowDataDir/$outputIntensityFile");
	$self->runCmd(0, "rm -f $workflowDataDir/$tempOutputFile");
	$self->runCmd(0, "rm -f $workflowDataDir/unNormAll.cov");
    } else {
	if ($test) {
	    $self->testInputFile('inputCoverageFile', "$workflowDataDir/$inputCoverageFile");
	    $self->testInputFile('inputGeneModelFile', "$workflowDataDir/$inputGeneModelFile");
	    $self->runCmd(0,"echo test > $workflowDataDir/$outputIntensityFile");
	}
	$self->runCmd($test, $cmd1);
	$self->runCmd($test, $cmd2);
	$self->runCmd($test, $cmd3);
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


