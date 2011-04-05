package ApiCommonWorkflow::Main::WorkflowSteps::GenerateChIPChipPeakFeatureGff;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;
use File::Basename;


sub run {
  my ($self, $test, $undo) = @_;

  my $inputFile = $self->getParamValue('inputFile');

  my $outputFile =  $self->getParamValue('outputFile');

  my $sampleOrder =  $self->getParamValue('sampleOrder');

  my $workflowDataDir = $self->getWorkflowDataDir();

  my $cmd = "generateChIP-ChipPeakFeatureGff  --inputFile '$workflowDataDir/$inputFile' --outputFile '$workflowDataDir/$outputFile' --sampleName '$sampleOrder'";
    
  if ($undo) {
      $self->runCmd(0, "rm -f $workflowDataDir/$outputFile");
  }else {
      if ($test){
	  $self->runCmd(0, "echo test> $workflowDataDir/$outputFile");
      }else{
	  $self->runCmd($test, $cmd);
      }
  }

}

sub getParamDeclaration {
  return (
	  'inputFile',
	  'outputFile',
	 );
}

sub getConfigDeclaration {
  return (
	  # [name, default, description]
	 );
}

