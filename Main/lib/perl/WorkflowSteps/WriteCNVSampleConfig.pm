package ApiCommonWorkflow::Main::WorkflowSteps::WriteCNVSampleConfig;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;


sub run {
  my ($self, $test, $undo) = @_;

  my $workflowDataDir = $self->getWorkflowDataDir();
  my $file = $self->getParamValue('file');
  my $configOutputFile = $self->getParamValue('configOutputFile');
  my $analysisName = $self->getParamValue('analysisName');
  my $protocolName = $self->getParamValue('protocolName');
  my $sampleDatasetName = $self->getParamValue('sampleDatasetName');

  my $cmd = "writeCNVConfig --file $workflowDataDir/$file --outputFile $workflowDataDir/$configOutputFile --name $analysisName --protocol $protocolName --sampleDatasetName $sampleDatasetName";

  if ($undo) {
    $self->runCmd(0, "rm $workflowDataDir/$configOutputFile");
  } else {
      if ($test) {
	    $self->runCmd(0,"echo test > $workflowDataDir/$configOutputFile");
      } 

      $self->runCmd($test, $cmd);
  }
}



1;
