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

    my $workflowDataDir = $self->getWorkflowDataDir();
    my $stepDir = $self->getStepDir();

    my $c;
    if ($transcriptOrGenome eq 'transcript') {$c = 'make_TU_and_TNU.pl'}
    elsif ($transcriptOrGenome eq 'genome') {$c = 'make_GU_and_GNU.pl'}
    else {$self->error("Illegal value for parameter 'transcriptOrGenome'.  Valid values are 'transcript' and 'genome'.")}

    my $cmd = "$c $bowtieFile $uFile $nuFile";

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
      );
}

sub getConfigDeclaration {
  return (
	  # [name, default, description]
	 );
}


