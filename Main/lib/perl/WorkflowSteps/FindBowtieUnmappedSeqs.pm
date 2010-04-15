package ApiCommonWorkflow::Main::WorkflowSteps::FindBowtieUnmappedSeqs;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;


sub run {
    my ($self, $test, $undo) = @_;

    my $readsFile = $self->getParamValue('inputSeqReadsFile');
    my $buFile = $self->getParamValue('inputBowtieUniqueFile');
    my $bnuFile = $self->getParamValue('inputBowtieNonUniqueFile');
    my $outFile = $self->getParamValue('outputBowtieUnmappedSeqsFile');
    my $readType = $self->getParamValue('readType');

    my $workflowDataDir = $self->getWorkflowDataDir();
    my $stepDir = $self->getStepDir();

    my $cmd = "make_unmapped_file.pl $readsFile $buFile $bnuFile $outFile $readType";

    if ($undo) {
	$self->runCmd(0, "rm -f $workflowDataDir/$outFile");
    } else {
	if ($test) {
	    $self->testInputFile('inputBowtieUniqueFile', "$workflowDataDir/$buFile");
	    $self->testInputFile('inputBowtieNonUniqueFile', "$workflowDataDir/$bnuFile");
	    $self->testInputFile('inputSeqReadsFile', "$workflowDataDir/$readsFile");

	    $self->runCmd(0,"echo test > $workflowDataDir/$outFile");

	}
	$self->runCmd($test, $cmd);

    }
}

sub getParamsDeclaration {
  return (
      'inputBowtieNonUniqueFile',
      'inputBowtieUniqueFile',
      'inputSeqReadsFile',
      'readType',
      'outputBowtieUnmappedSeqsFile',
      );
}

sub getConfigDeclaration {
  return (
	  # [name, default, description]
	 );
}


