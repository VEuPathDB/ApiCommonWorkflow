package ApiCommonWorkflow::Main::WorkflowSteps::SsaFindBowtieUnmappedSeqs;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;


sub run {
    my ($self, $test, $undo) = @_;

    my $shortSeqsFile = $self->getParamValue('inputShortSeqsFile');
    my $buFile = $self->getParamValue('inputBowtieUniqueFile');
    my $bnuFile = $self->getParamValue('inputBowtieNonUniqueFile');
    my $outFile = $self->getParamValue('outputBowtieUnmappedSeqsFile');
    my $readType = $self->getParamValue('readType');

    my $workflowDataDir = $self->getWorkflowDataDir();
    my $stepDir = $self->getStepDir();

    my $cmd = "make_unmapped_file.pl $workflowDataDir/$shortSeqsFile $workflowDataDir/$buFile $workflowDataDir/$bnuFile $workflowDataDir/$outFile $readType";

    if ($undo) {
	$self->runCmd(0, "rm -f $workflowDataDir/$outFile");
    } else {
      $self->testInputFile('inputBowtieUniqueFile', "$workflowDataDir/$buFile");
      $self->testInputFile('inputBowtieNonUniqueFile', "$workflowDataDir/$bnuFile");
      $self->testInputFile('inputShortSeqsFile', "$workflowDataDir/$shortSeqsFile");

      if ($test) {
        $self->runCmd(0,"echo test > $workflowDataDir/$outFile");
      }
      $self->runCmd($test, $cmd);
    }
}


1;
