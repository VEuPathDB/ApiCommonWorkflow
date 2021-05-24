package ApiCommonWorkflow::Main::WorkflowSteps::ProteinBlatToGFF;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test, $undo) = @_;

  my $inputFile = $self->getParamValue('inputFile');
  my $unsortedOutputFile = $self->getParamValue('unsortedOutputFile');
  my $sortedOutputFile = $self->getParamValue('sortedOutputFile');
  
  my $workflowDataDir = $self->getWorkflowDataDir();

  my $cmd = "proteinBlatToGFF.pl --blat_file $workflowDataDir/$inputFile --output_file $workflowDataDir/$unsortedOutputFile";

  if ($undo) {
    $self->runCmd(0, "rm -f $workflowDataDir/$unsortedOutputFile");
    $self->runCmd(0, "rm -f $workflowDataDir/$sortedOutputFile");
    $self->runCmd(0, "rm -f $workflowDataDir/$sortedOutputFile.gz");
  } else {  
    $self->testInputFile('inputFile', "$workflowDataDir/$inputFile");
    if ($test) {
	  $self->runCmd(0,"echo test > $workflowDataDir/$unsortedOutputFile");
    }
    $self->runCmd($test,"sort -k1,1 -k4,4n $workflowDataDir/$unsortedOutputFile > $workflowDataDir/$sortedOutputFile");
    $self->runCmd($test,"bgzip $workflowDataDir/$sortedOutputFile");
    $self->runCmd($test,"tabix -p gff $workflowDataDir/$sortedOutputFile.gz");
  }
}

1;


