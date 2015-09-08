package ApiCommonWorkflow::Main::WorkflowSteps::WriteGenomicArrayStudyConfig;

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
  my $sourceIdType = $self->getParamValue('sourceIdType');

  my $profileSetName = $self->getParamValue('profileSetName');

  my $inputProtocolAppNode = $self->getParamValue('inputProtocolAppNode');

  my $paramValues = "--file $file --outputFile $workflowDataDir/$configOutputFile --name '$analysisName' --protocol '$protocolName' --sourceIdType $sourceIdType --profileSetName '$profileSetName'";

  if (defined $inputProtocolAppNode) {
    $paramValues = $paramValues." --inputProtocolAppNodes '$inputProtocolAppNode'";
    }

  my $cmd = "writeStudyConfig $paramValues";

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
