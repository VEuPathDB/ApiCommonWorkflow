package ApiCommonWorkflow::Main::WorkflowSteps::RecreateNdfFile;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;


sub run {
  my ($self, $test, $undo) = @_;

  my $gene2probesInputFile = $self->getParamValue('gene2probesInputFile');
  my $ndfFile = $self->getParamValue('inputNdfFile');
  my $outputFile = $self->getParamValue('outputNdfFile');

  my $workflowDataDir = $self->getWorkflowDataDir();

  my $cmd = "recreate_ndf.pl --original_ndf_file $workflowDataDir/$ndfFile --gene_to_oligo_file $workflowDataDir/$gene2probesInputFile --output_file $workflowDataDir/$outputFile";

  if ($undo) {
    $self->runCmd(0, "rm -f $workflowDataDir/$outputFile");
  } else {
    $self->testInputFile('originalNdfFile', "$workflowDataDir/$ndfFile");
    $self->testInputFile('gene2probesInputFile', "$workflowDataDir/$gene2probesInputFile");

    if ($test) {
      $self->runCmd(0,"echo test > $workflowDataDir/$outputFile");
    }
    $self->runCmd($test,$cmd);

  }
}

1;
