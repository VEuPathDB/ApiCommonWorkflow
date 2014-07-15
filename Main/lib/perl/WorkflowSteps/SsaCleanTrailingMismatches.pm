package ApiCommonWorkflow::Main::WorkflowSteps::SsaCleanTrailingMismatches;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
    my ($self, $test, $undo) = @_;

    my $inputUFile = $self->getParamValue('inputUniqueFile');
    my $inputNuFile = $self->getParamValue('inputNonUniqueFile');
    my $outputUFile = $self->getParamValue('outputUniqueFile');
    my $outputNuFile = $self->getParamValue('outputNonUniqueFile');
    my $genomicSeqsFile = $self->getParamValue('genomicSeqsFile');
    my $reportMismatches = $self->getBooleanParamValue('reportMismatches');

    my $workflowDataDir = $self->getWorkflowDataDir();
    my $stepDir = $self->getStepDir();

    my $cmd = "RUM_finalcleanup.pl $workflowDataDir/$inputUFile $workflowDataDir/$inputNuFile $workflowDataDir/$outputUFile $workflowDataDir/$outputNuFile  $workflowDataDir/$genomicSeqsFile";

    $cmd .= " -countmismatches" if ($reportMismatches);

    if ($undo) {
	$self->runCmd(0, "rm -f $workflowDataDir/$outputUFile");
	$self->runCmd(0, "rm -f $workflowDataDir/$outputNuFile");
    } else {

      $self->testInputFile('inputUniqueFile', "$workflowDataDir/$inputUFile");
      $self->testInputFile('inputNonUniqueFile', "$workflowDataDir/$inputNuFile");
      $self->testInputFile('genomicSeqsFile', "$workflowDataDir/$genomicSeqsFile");

      if ($test) {
        $self->runCmd(0,"echo test > $workflowDataDir/$outputUFile");
        $self->runCmd(0,"echo test > $workflowDataDir/$outputNuFile");
      }
      $self->runCmd($test, $cmd);
    }
}

1;

