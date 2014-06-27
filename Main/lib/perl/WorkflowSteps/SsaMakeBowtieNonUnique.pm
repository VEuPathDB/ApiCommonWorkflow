package ApiCommonWorkflow::Main::WorkflowSteps::SsaMakeBowtieNonUnique;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;


sub run {
    my ($self, $test, $undo) = @_;

    my $gnuFile = $self->getParamValue('inputGenomeNonUniqueFile');
    my $tnuFile = $self->getParamValue('inputTranscriptNonUniqueFile');
    my $cnuFile = $self->getParamValue('inputCombinedNonUniqueFile');
    my $bnuFile = $self->getParamValue('outputBowtieNonUniqueFile');

    my $workflowDataDir = $self->getWorkflowDataDir();
    my $stepDir = $self->getStepDir();

    my $cmd = "merge_GNU_and_TNU_and_CNU.pl $workflowDataDir/$gnuFile $workflowDataDir/$tnuFile $workflowDataDir/$cnuFile $workflowDataDir/$bnuFile";

    if ($undo) {
	$self->runCmd(0, "rm -f $workflowDataDir/$bnuFile");
    } else {
      $self->testInputFile('inputGenomeNonUniqueFile', "$workflowDataDir/$gnuFile");
      $self->testInputFile('inputTrancriptNonUniqueFile', "$workflowDataDir/$tnuFile");
      $self->testInputFile('inputCombinedNonUniqueFile', "$workflowDataDir/$cnuFile");

      if ($test) {
        $self->runCmd(0,"echo test > $workflowDataDir/$bnuFile");
      }
      $self->runCmd($test, $cmd);
    }
}

1;
