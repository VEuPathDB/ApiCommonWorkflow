package ApiCommonWorkflow::Main::WorkflowSteps::MapArrayProbesToArrayElementFeatures;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;


sub run {
  my ($self, $test, $undo) = @_;

  my $inputFile = $self->getParamValue('inputFile');
  my $outputFile =  $self->getParamValue('outputFile');
  my $extDbRlsSpec = $self->getParamValue('extDbRlsSpec');

  my $workflowDataDir = $self->getWorkflowDataDir();

  my $cmd = "reformatChIP-ChipSmoothedProfiles.pl  --inputFile $workflowDataDir/$inputFile --aefExtDbSpec '$extDbRlsSpec'> $workflowDataDir/$outputFile";

  my $cmd = "mapProbesToArrayElementFeatures.pl --aefExtDbSpec '$extDbRlsSpec' --inputFile $workflowDataDir/$inputFile --outputFile $workflowDataDir/$outputFile";

  if ($undo) {
      $self->runCmd(0, "rm -f $workflowDataDir/$outputFile");
  }else {
    if ($test){
      $self->runCmd(0, "echo test > $workflowDataDir/$outputFile");
    }
    $self->runCmd($test, $cmd);

  }

}

1;
