package ApiCommonWorkflow::Main::WorkflowSteps::FindNrdbXrefs;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);
use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test, $undo) = @_;

  # get parameters
  my $proteinsFile = $self->getParamValue('proteinsFile');
  my $nrdbFile = $self->getParamValue('nrdbFile');
  my $proteinsFileRegex = $self->getParamValue('proteinsFileRegex');
  my $nrdbFileRegex = $self->getParamValue('nrdbFileRegex');
  my $outputFile = $self->getParamValue('outputFile');

  my $workflowDataDir = $self->getWorkflowDataDir();

  my $cmd = "dbXRefBySeqIdentity --proteinFile '$workflowDataDir/$proteinsFile' --nrFile '$workflowDataDir/$nrdbFile' --outputFile '$workflowDataDir/$outputFile' --sourceIdRegex \"$nrdbFileRegex\" --protDeflnRegex \"$proteinsFileRegex\" ";

  if ($undo) {
    $self->runCmd(0, "rm -f $workflowDataDir/$outputFile");
  } else {
    $self->testInputFile('proteinsFile', "$workflowDataDir/$proteinsFile");
    $self->testInputFile('nrdbFile', "$workflowDataDir/$nrdbFile");

      if ($test) {
	  $self->runCmd(0, "echo test > $workflowDataDir/$outputFile");
      }
	  $self->error("Proteins file '$workflowDataDir/$proteinsFile' does not exist or is empty") unless -s "$workflowDataDir/$proteinsFile";
	  $self->runCmd($test,$cmd);
  }
}

1;
