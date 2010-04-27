package ApiCommonWorkflow::Main::WorkflowSteps::MergeBowtieAndBlat;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
    my ($self, $test, $undo) = @_;

    my $bowtieUFile = $self->getParamValue('inputBowtieUniqueFile');
    my $bowtieNuFile = $self->getParamValue('inputBowtieNonUniqueFile');
    my $blatUFile = $self->getParamValue('inputBlatUniqueFile');
    my $blatNuFile = $self->getParamValue('inputBlatNonUniqueFile');
    my $uFile = $self->getParamValue('outputUniqueFile');
    my $nuFile = $self->getParamValue('outputNonUniqueFile');
    my $readType = $self->getParamValue('readType');

    $self->error() unless ($readType eq 'single' or $readType eq 'paired');

    my $workflowDataDir = $self->getWorkflowDataDir();
    my $stepDir = $self->getStepDir();

    my $cmd = "merge_Bowtie_and_Blat.pl $workflowDataDir/$bowtieUFile $workflowDataDir/$blatUFile $workflowDataDir/$bowtieNuFile $workflowDataDir/$blatNuFile $workflowDataDir/$uFile $workflowDataDir/$nuFile $readType";

    if ($undo) {
	$self->runCmd(0, "rm -f $workflowDataDir/$uFile");
	$self->runCmd(0, "rm -f $workflowDataDir/$nuFile");
    } else {
	if ($test) {
	    $self->testInputFile('inputBowtieUniqueFile', "$workflowDataDir/$bowtieUFile");
	    $self->testInputFile('inputBowtieNonUniqueFile', "$workflowDataDir/$bowtieNuFile");
	    $self->testInputFile('inputBlatUniqueFile', "$workflowDataDir/$blatUFile");
	    $self->testInputFile('inputBlatNonUniqueFile', "$workflowDataDir/$blatNuFile");

	    $self->runCmd(0,"echo test > $workflowDataDir/$uFile");
	    $self->runCmd(0,"echo test > $workflowDataDir/$nuFile");

	}
	$self->runCmd($test, $cmd);

    }
}

sub getParamsDeclaration {
  return (
      'inputBlatUniqueFile',
      'inputBlatNonUniqueFile',
      'inputBowtieUniqueFile',
      'inputBowtieNonUniqueFile',
      'outputUniqueFile',
      'outputNonUniqueFile',
      'readType',
      );
}

sub getConfigDeclaration {
  return (
	  # [name, default, description]
	 );
}


