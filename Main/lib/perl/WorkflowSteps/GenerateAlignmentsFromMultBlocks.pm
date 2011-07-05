package ApiCommonWorkflow::Main::WorkflowSteps::GenerateAlignmentsFromMultBlocks;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
    my ($self, $test, $undo) = @_;

    my $inputFile = $self->getParamValue('inputFile');
    my $outputFile = $self->getParamValue('outputFile');
    my $sampleName = $self->getParamValue('sampleName');
    my $fileType = $self->getParamValue('fileType');
    my $extDbSpecs = $self->getParamValue('extDbSpecs');
    my $maxGenomeMatch = $self->getParamValue('maxGenomeMatch');

    my $workflowDataDir = $self->getWorkflowDataDir();
    my $stepDir = $self->getStepDir();

    my $cmd = "generateAlignmentsFromMultBlocks.pl --f $workflowDataDir/$inputFile --sample $sampleName --ft $fileType --extDbSpecs $extDbSpecs --m $maxGenomeMatch > $workflowDataDir/$outputFile";


    if ($undo) {
	$self->runCmd(0, "rm -f $workflowDataDir/$outputFile");
    } else {
	if ($test) {
	    $self->testInputFile('inputCoverageFile', "$workflowDataDir/$inputFile");
	    $self->runCmd(0,"echo test > $workflowDataDir/$outputFile");
	}
	$self->runCmd($test, $cmd);
    }
}

sub getParamsDeclaration {
  return (
      'inputFile',
      'sampleName',
      'outputFile',
      'fileType',
      'extDbSpecs',
      'maxGenomeMatch',
      );
}

sub getConfigDeclaration {
  return (
	  # [name, default, description]
	 );
}


