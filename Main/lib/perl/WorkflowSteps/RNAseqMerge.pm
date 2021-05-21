package ApiCommonWorkflow::Main::WorkflowSteps::RNAseqMerge;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);
use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test, $undo) = @_;

  # get parameters
  my $inputsDir = $self->getParamValue('inputsDir');
  my $chromSizesFile = $self->getParamValue('chromSizesFile');
  my $experimentName = $self->getParamValue('experimentName');
  my $analysisConfig = $self->getParamValue('analysisConfig');

  my $workflowDataDir = $self->getWorkflowDataDir();

  my $cmd = "rnaseqMerge.pl --dir $workflowDataDir/$inputsDir --experimentName $experimentName --chromSize $workflowDataDir/$chromSizesFile --analysisConfig $workflowDataDir/$analysisConfig";

  if ($undo) {
    $self->runCmd(0, "rm -rf $workflowDataDir/$inputsDir/mergedBigwigs");
  } else {
    if ($test) {
        $self->testInputFile('inputsDir', "$workflowDataDir/$inputsDir");
        $self->testInputFile('analysisConfig', "$workflowDataDir/$analysisConfig");
        $self->testInputFile('chromSizes', "$workflowDataDir/$chromSizesFile");
        $self->runCmd(0, "mkdir $workflowDataDir/$inputsDir/mergedBigwigs");
    }
    $self->runCmd($test, $cmd);
  }

}

1;


