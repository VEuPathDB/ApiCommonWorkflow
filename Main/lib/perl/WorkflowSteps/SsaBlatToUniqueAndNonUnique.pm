package ApiCommonWorkflow::Main::WorkflowSteps::SsaBlatToUniqueAndNonUnique;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;


sub run {
    my ($self, $test, $undo) = @_;

    my $shortSeqsFile = $self->getParamValue('inputShortSeqsFile');
    my $blatFile = $self->getParamValue('inputBlatFile');
    my $mdustFile = $self->getParamValue('inputMdustFile');
    my $uFile = $self->getParamValue('outputUniqueFile');
    my $nuFile = $self->getParamValue('outputNonUniqueFile');
    my $readLength = $self->getParamValue('readLength');
    my $isChipSeq = $self->getParamValue('isChipSeq');
    my $nonUniqueMappingSuppressLimits = $self->getParamValue('nonUniqueMappingSuppressLimits');

    my $workflowDataDir = $self->getWorkflowDataDir();
    my $stepDir = $self->getStepDir();

    my $chipseqFlag;
    if ($isChipSeq eq 'true') {$chipseqFlag = '-chipseq'}
    elsif ($isChipSeq eq 'false') {$chipseqFlag = ''}
    else { $self->error("Invalid value '$isChipSeq' for isChipSeq param. Must be 'true' or 'false'");}

    my $cmd = "parse_blat_out.pl $workflowDataDir/$shortSeqsFile $workflowDataDir/$blatFile $workflowDataDir/$mdustFile $workflowDataDir/$uFile $workflowDataDir/$nuFile $readLength $chipseqFlag";

    if ($undo) {
	$self->runCmd(0, "rm -f $workflowDataDir/$uFile");
	$self->runCmd(0, "rm -f $workflowDataDir/$nuFile");
    } else {
	if ($test) {
	    $self->testInputFile('inputShortSeqsFile', "$workflowDataDir/$shortSeqsFile");
	    $self->testInputFile('inputBlatFile', "$workflowDataDir/$blatFile");
	    $self->testInputFile('inputMdustFile', "$workflowDataDir/$mdustFile");

	    $self->runCmd(0,"echo test > $workflowDataDir/$uFile");
	    $self->runCmd(0,"echo test > $workflowDataDir/$nuFile");

	}
	$self->runCmd($test, $cmd);

    }
}

sub getParamsDeclaration {
  return (
    'inputShortSeqsFile',
    'inputBlatFile',
    'inputMdustFile',
    'outputUniqueFile',
    'outputNonUniqueFile',
    'readLength',
    'isChipSeq',
      );
}

sub getConfigDeclaration {
  return (
	  # [name, default, description]
	 );
}


