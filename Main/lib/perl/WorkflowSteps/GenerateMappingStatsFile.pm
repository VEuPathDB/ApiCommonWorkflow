package ApiCommonWorkflow::Main::WorkflowSteps::GenerateMappingStatsFile;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;
use File::Basename;


sub run {
  my ($self, $test, $undo) = @_;

  my $uniqueFile = $self->getParamValue('uniqueFile');

  my $nonUniqueFile = $self->getParamValue('nonUniqueFile');

  my $outputFile =  $self->getParamValue('outputFile');

  my $workflowDataDir = $self->getWorkflowDataDir();

  my $cmd = "count_reads_mapped.pl '$workflowDataDir/$uniqueFile' '$workflowDataDir/$nonUniqueFile' > '$workflowDataDir/$outputFile'";
    
  if ($undo) {
      $self->runCmd(0, "rm -f $workflowDataDir/$outputFile");
  }else {
    if ($test){
      $self->runCmd(0, "echo test> $workflowDataDir/$outputFile");
    }
    $self->runCmd($test, $cmd);

  }

}

1;
