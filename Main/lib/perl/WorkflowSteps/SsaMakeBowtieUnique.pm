package ApiCommonWorkflow::Main::WorkflowSteps::SsaMakeBowtieUnique;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;


sub run {
    my ($self, $test, $undo) = @_;

    my $gnuFile = $self->getParamValue('inputGenomeNonUniqueFile');
    my $tnuFile = $self->getParamValue('inputTranscriptNonUniqueFile');
    my $guFile = $self->getParamValue('inputGenomeUniqueFile');
    my $tuFile = $self->getParamValue('inputTranscriptUniqueFile');
    my $buFile = $self->getParamValue('outputBowtieUniqueFile');
    my $cnuFile = $self->getParamValue('outputCombinedNonUniqueFile');
    my $readType = $self->getParamValue('readType');

    $self->error() unless ($readType eq 'single' or $readType eq 'paired');

    my $workflowDataDir = $self->getWorkflowDataDir();
    my $stepDir = $self->getStepDir();

    my $cmd = "merge_GU_and_TU.pl $workflowDataDir/$guFile $workflowDataDir/$tuFile $workflowDataDir/$gnuFile $workflowDataDir/$tnuFile $workflowDataDir/$buFile $workflowDataDir/$cnuFile $readType";

    if ($undo) {
	$self->runCmd(0, "rm -f $workflowDataDir/$buFile");
	$self->runCmd(0, "rm -f $workflowDataDir/$cnuFile");
    } else {
	if ($test) {
	    $self->testInputFile('inputTrancriptUniqueFile', "$workflowDataDir/$tuFile");
	    $self->testInputFile('inputGenomeUniqueFile', "$workflowDataDir/$guFile");
	    $self->testInputFile('inputTrancriptNonUniqueFile', "$workflowDataDir/$tnuFile");
	    $self->testInputFile('inputGenomeNonUniqueFile', "$workflowDataDir/$gnuFile");

	    $self->runCmd(0,"echo test > $workflowDataDir/$buFile");
	    $self->runCmd(0,"echo test > $workflowDataDir/$cnuFile");

	}
	$self->runCmd($test, $cmd);

    }
}

sub getParamsDeclaration {
  return (
      'inputGenomeNonUniqueFile',
      'inputTranscriptNonUniqueFile',
      'inputGenomeUniqueFile',
      'inputTranscriptUniqueFile',
      'outputBowtieUniqueFile',
      'outputCombinedNonUniqueFile',
      'readType',
      );
}

sub getConfigDeclaration {
  return (
	  # [name, default, description]
	 );
}


