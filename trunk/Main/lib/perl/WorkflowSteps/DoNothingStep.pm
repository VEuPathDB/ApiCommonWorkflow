package ApiCommonWorkflow::Main::WorkflowSteps::DoNothingStep;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;


sub run {
  my ($self, $test, $undo) = @_;

    my $outputDir = $self->getParamValue('outputDir');

    my $outputFile = $self->getParamValue('outputFile');

    my $workflowDataDir = $self->getWorkflowDataDir();

    if ($undo) {
      $self->runCmd(0, "rm -f $workflowDataDir/$outputFile ") if $outputFile;
      $self->runCmd(0, "rm -fr $workflowDataDir/$outputDir/") if $outputDir;
    } else {
    if ($test) {
      $self->runCmd(0, "mkdir -p $workflowDataDir/$outputDir/") if $outputDir;
      $self->runCmd(0, "echo test > $workflowDataDir/$outputFile") if $outputFile;
    }
  }
}

sub getParamsDeclaration {
  return ('',
	 );
}

sub getConfigDeclaration {
  return (
	  # [name, default, description]
	 );
}



