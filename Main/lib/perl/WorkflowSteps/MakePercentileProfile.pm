package ApiCommonWorkflow::Main::WorkflowSteps::MakePercentileProfile;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;


sub run {
  my ($self, $test, $undo) = @_;

  my $inputFile = $self->getParamValue('inputFile');
  my $outputFile = $self->getParamValue('outputFile');
  my $ties = $self->getParamValue('ties');
  my $hasHeader = $self->getParamValue('hasHeader');

  my $workflowDataDir = $self->getWorkflowDataDir();

  my $cmd = "percentile.pl --input_file $workflowDataDir/$inputFile --output_file $workflowDataDir/$outputFile --ties $ties";

  $cmd .= " --hasHeader" if $hasHeader;

  if ($undo) {
    $self->runCmd(0, "rm -f $workflowDataDir/$outputFile");
  } else {
      if ($test) {
	  $self->testInputFile('seqFile', "$workflowDataDir/$inputFile");
	  $self->runCmd(0,"echo test > $workflowDataDir/$outputFile");
      }else{
	  $self->runCmd($test,$cmd);
      }
  }
}

sub getParamDeclaration {
  return (
	  'inputFile',
	  'ties',
	  'outputFile',
	  'hasHeader',
	 );
}

sub getConfigDeclaration {
  return (
	  # [name, default, description]
	 );
}

