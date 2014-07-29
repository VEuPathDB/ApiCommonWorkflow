package ApiCommonWorkflow::Main::WorkflowSteps::FindTandemRepeats;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;


sub run {
  my ($self, $test, $undo) = @_;

  my $seqsFile = $self->getParamValue('seqsFile');
  my $repeatFinderArgs = $self->getParamValue('repeatFinderArgs');
  my $outputFile = $self->getParamValue('outputFile');

  my $trfPath = $self->getConfig('trfPath');

  my $workflowDataDir = $self->getWorkflowDataDir();
  my $stepDir = $self->getStepDir();

  my $cmd = "trfWrap --trfPath $trfPath --inputFile $workflowDataDir/$seqsFile --args '$repeatFinderArgs' 2>>command.log";

  $repeatFinderArgs =~ s/\s+/\./g;

  if ($undo) {
    $self->runCmd(0, "rm -f $workflowDataDir/$outputFile");
  } else {
    $self->testInputFile('seqsFile', "$workflowDataDir/$seqsFile");
    if ($test) {
      $self->runCmd(0,"echo test > $workflowDataDir/$outputFile");
    }
    $self->runCmd($test, $cmd);
    $self->runCmd($test, "mv $stepDir/genomicSeqs.fa.$repeatFinderArgs.dat $workflowDataDir/$outputFile");
  }

}
1;
