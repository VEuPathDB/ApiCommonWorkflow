package ApiCommonWorkflow::Main::WorkflowSteps::SsaBowtieToUniqueAndNonUnique;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;


sub run {
    my ($self, $test, $undo) = @_;

    my $bowtieFile = $self->getParamValue('inputBowtieFile');
    my $uFile = $self->getParamValue('outputUniqueFile');
    my $nuFile = $self->getParamValue('outputNonUniqueFile');
    my $transcriptOrGenome = $self->getParamValue('transcriptOrGenome');
    my $readType = $self->getParamValue('readType');

    my $workflowDataDir = $self->getWorkflowDataDir();
    my $stepDir = $self->getStepDir();

    my $c;
    if ($transcriptOrGenome eq 'transcript') {$c = 'make_TU_and_TNU.pl'}
    elsif ($transcriptOrGenome eq 'genome') {$c = 'make_GU_and_GNU.pl'}
    else {$self->error("Illegal value '$transcriptOrGenome' for parameter 'transcriptOrGenome'.  Valid values are 'transcript' and 'genome'.")}

    if ($readType ne 'single' && $readType ne 'paired') {
	$self->error("Illegal value '$readType' for parameter 'readType'.  Valid values are 'single' and 'paired'."
    }

    my $cmd = "$c $bowtieFile $uFile $nuFile $readType";

    if ($undo) {
	$self->runCmd(0, "rm -f $workflowDataDir/$uFile");
	$self->runCmd(0, "rm -f $workflowDataDir/$nuFile");
    } else {
	if ($test) {
	    $self->testInputFile('inputBowtieFile', "$workflowDataDir/$bowtieFile");

	    $self->runCmd(0,"echo test > $workflowDataDir/$uFile");
	    $self->runCmd(0,"echo test > $workflowDataDir/$nuFile");

	}
	$self->runCmd($test, $cmd);

    }
}

sub getParamsDeclaration {
  return (
      'inputBowtieFile',
      'outputUniqueFile',
      'outputNonUniqueFile',
      'transcriptOrGenome',
      'readType'
      );
}

sub getConfigDeclaration {
  return (
	  # [name, default, description]
	 );
}


