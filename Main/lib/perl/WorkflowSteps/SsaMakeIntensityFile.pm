package ApiCommonWorkflow::Main::WorkflowSteps::SsaMakeIntensityFile;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
    my ($self, $test, $undo) = @_;

    my $inputSortedFile = $self->getParamValue('inputSortedFile');
    my $inputGeneModelFile = $self->getParamValue('inputGeneModelFile');
    my $outputIntensityFileBasename = $self->getParamValue('outputIntensityFileBasename');

    my $strand = $self->getParamValue('strand');
    my $strandParam;
    if($strand eq 'plus') {
      $strandParam = "-strand p";
    }
    if($strand eq 'minus') {
      $strandParam = "-strand m";
    }

    my $antisense = $self->getBooleanParamValue('antisense');

    if($antisense && !$strand) {
      $self->error("Cannot make antisense probes unless the data is for a specific strand");
    }

    my $antisenseParam;
    if($antisense) {
      $antisenseParam = "-anti";
    }

    my $workflowDataDir = $self->getWorkflowDataDir();
    my $stepDir = $self->getStepDir();

    my ($uniqueSorted,$nuSorted) = split(',',$inputSortedFile);

    my $tempOutputFile="$workflowDataDir/$outputIntensityFileBasename.tmp";

    my $cmd1 = "rum2quantifications.pl $workflowDataDir/$inputGeneModelFile $workflowDataDir/$uniqueSorted $workflowDataDir/$nuSorted $tempOutputFile $strandParam $antisenseParam";

    my $cmd2 = "featurequant2geneprofiles.pl $workflowDataDir/$outputIntensityFileBasename $tempOutputFile  -genes";

    if ($undo) {
	$self->runCmd(0, "rm -f $workflowDataDir/$outputIntensityFileBasename.*");
    } else {
	if ($test) {
	    $self->testInputFile('inputUniqueSortedFile', "$workflowDataDir/$uniqueSorted");
	    $self->testInputFile('inputNUSortedFile', "$workflowDataDir/$nuSorted");
	    $self->runCmd(0,"echo test > $workflowDataDir/$outputIntensityFileBasename.min");
            $self->runCmd(0,"echo test > $workflowDataDir/$outputIntensityFileBasename.max");
	}
	$self->runCmd($test, $cmd1);
	$self->runCmd($test, $cmd2);
    }
}

sub getConfigDeclaration {
  return (
	  # [name, default, description]
	 );
}


