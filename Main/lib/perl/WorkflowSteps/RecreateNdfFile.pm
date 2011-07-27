package ApiCommonWorkflow::Main::WorkflowSteps::RecreateNdfFile;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;


sub run {
  my ($self, $test, $undo) = @_;

  my $gene2probesInputFile = $self->getParamValue('gene2probesInputFile');
  my $ndfFile = $self->getParamValue('originalNdfFile');
  my $outputFile = $self->getParamValue('outputNdfFile');

  my $workflowDataDir = $self->getWorkflowDataDir();

  my $cmd = "recreate_ndf.pl --original_ndf_file $workflowDataDir/$ndfFile --gene_to_oligo_file $workflowDataDir/$gene2probesInputFile --output_file $workflowDataDir/$outputFile";

  if ($undo) {
    $self->runCmd(0, "rm -f $workflowDataDir/$outputFile");
  } else {
      if ($test) {
	  $self->testInputFile('originalNdfFile', "$workflowDataDir/$ndfFile");
	  $self->testInputFile('gene2probesInputFile', "$workflowDataDir/$gene2probesInputFile");
      }else{
	  $self->runCmd($test,$cmd);
      }
  }
}

sub getParamDeclaration {
  return (
	  'gene2probesInputFile',
	  'ndfFile',
	 );
}

sub getConfigDeclaration {
  return (
	  # [name, default, description]
	 );
}

