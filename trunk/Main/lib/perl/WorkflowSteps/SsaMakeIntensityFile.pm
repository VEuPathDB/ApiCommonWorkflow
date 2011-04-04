package ApiCommonWorkflow::Main::WorkflowSteps::SsaMakeIntensityFile;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
    my ($self, $test, $undo) = @_;

    my $inputSortedFile = $self->getParamValue('inputSortedFile');
    my $inputGeneModelFile = $self->getParamValue('inputGeneModelFile');
    my $outputIntensityFile = $self->getParamValue('outputIntensityFile');

    my $workflowDataDir = $self->getWorkflowDataDir();
    my $stepDir = $self->getStepDir();

    my ($uniqueSorted,$nuSorted) = split(',',$inputSortedFile);

    my $tempOutputFile="$workflowDataDir/$outputIntensityFile"."ori";

    my $cmd1 = "rum2quantifications.pl $workflowDataDir/$inputGeneModelFile $workflowDataDir/$uniqueSorted $workflowDataDir/$nuSorted $tempOutputFile";

    my $cmd2 = "featurequant2geneprofiles.pl $workflowDataDir/$outputIntensityFile $tempOutputFile  -genes";

    if ($undo) {
	$self->runCmd(0, "rm -f $workflowDataDir/$outputIntensityFile.min");
        $self->runCmd(0, "rm -f $workflowDataDir/$outputIntensityFile.max");
        $self->runCmd(0, "rm -f $workflowDataDir/$outputIntensityFile.intori");
    } else {
	if ($test) {
	    $self->testInputFile('inputUniqueSortedFile', "$workflowDataDir/$uniqueSorted");
	    $self->testInputFile('inputNUSortedFile', "$workflowDataDir/$nuSorted");
	    $self->testInputFile('inputGeneModelFile', "$workflowDataDir/$inputGeneModelFile");
	    $self->runCmd(0,"echo test > $workflowDataDir/$outputIntensityFile.min");
            $self->runCmd(0,"echo test > $workflowDataDir/$outputIntensityFile.max");
	}
	$self->runCmd($test, $cmd1);
	$self->runCmd($test, $cmd2);
    }
}

sub getParamsDeclaration {
  return (
      'inputGeneModelFile',
      'inputSortedFile',
      'outputIntensityFile',
      );
}

sub getConfigDeclaration {
  return (
	  # [name, default, description]
	 );
}


