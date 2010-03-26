package ApiCommonWorkflow::Main::WorkflowSteps::GrepMercatorGff;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);
use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;


sub run {
  my ($self, $test, $undo) = @_;

  # get parameters
  my $inputFile = $self->getParamValue('inputFile');
  my $outputFile = $self->getParamValue('outputFile');

  my $workflowDataDir = $self->getWorkflowDataDir();

  my $cmd = "grep -P '\texon\t' ${workflowDataDir}/$inputFile |sed 's/apidb|//'  > ${workflowDataDir}/$outputFile; grep -P '\tCDS\t' ${workflowDataDir}/$inputFile |sed 's/apidb|//'  > ${workflowDataDir}/$outputFile";

  if ($test) {
    $self->runCmd(0, "echo test > ${workflowDataDir}/$outputFile");
  }elsif ($undo) {
    $self->runCmd(0, "rm -f $workflowDataDir/$outputFile");
  }else {
    $self->runCmd($test, $cmd);
  }

}

sub getParamsDeclaration {
  return (
          'inputFile',
          'outputFile',
         );
}

sub getConfigDeclaration {
  return (
         # [name, default, description]
         # ['', '', ''],
         );
}

