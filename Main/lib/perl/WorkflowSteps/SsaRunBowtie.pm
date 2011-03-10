package ApiCommonWorkflow::Main::WorkflowSteps::SsaRunBowtie;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
    my ($self, $test, $undo) = @_;

    my $inputIndexesDir = $self->getParamValue('inputIndexesDir');
    my $inputShortSeqsFile = $self->getParamValue('inputShortSeqsFile');
    my $outputFile = $self->getParamValue('outputFile');
    my $bowtieParam = $self->getParamValue('bowtieParam');
    my $inputShortSeqsFileType = $self->getParamValue('inputShortSeqsFileType');

    my $workflowDataDir = $self->getWorkflowDataDir();
    my $stepDir = $self->getStepDir();

    my $cmd = "bowtie $bowtieParam --best --strata $workflowDataDir/$inputIndexesDir/genomicIndexes $inputShortSeqsFileType $workflowDataDir/$inputShortSeqsFile > $workflowDataDir/$outputFile";

    if ($undo) {
	$self->runCmd(0, "rm -f $workflowDataDir/$outputFile");
    } else {
	if ($test) {
	    $self->testInputFile('inputCoverageFile', "$workflowDataDir/$inputIndexesDir");
	    $self->testInputFile('inputShortSeqsFile', "$workflowDataDir/$inputShortSeqsFile");
	    $self->runCmd(0,"echo test > $workflowDataDir/$outputFile");
	}
	$self->runCmd($test, $cmd);
    }
}

sub getParamsDeclaration {
  return (
      'inputIndexesDir',
      'inputShortSeqsFile',
      'outputFile',
      );
}

sub getConfigDeclaration {
  return (
	  # [name, default, description]
	 );
}


