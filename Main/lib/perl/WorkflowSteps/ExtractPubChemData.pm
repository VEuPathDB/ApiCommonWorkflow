package ApiCommonWorkflow::Main::WorkflowSteps::ExtractPubChemData;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;
use File::Basename;


sub run {
  my ($self, $test, $undo) = @_;

  my $idFile = $self->getParamValue('idFile');
  my $outFile =  $self->getParamValue('outFile');
  my $type =  $self->getParamValue('type');
  my $property =  $self->getParamValue('property');
  my $workflowDataDir = $self->getWorkflowDataDir();

  my $cmd = "extractPubChemData  --idFile '$workflowDataDir/$idFile' --outFile '$workflowDataDir/$outFile' --type '$type'";
  $cmd .= "  --property '$property'" if $property;



  if ($undo) {
    $self->runCmd(0, "rm -f $workflowDataDir/$outFile");
  }else {
    $self->testInputFile('inputFile', "$workflowDataDir/$idFile");
    if ($test){
      $self->runCmd(0, "echo test> $workflowDataDir/$outFile");
    }
    $self->runCmd($test, $cmd);
  }
}

1;

