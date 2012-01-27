package ApiCommonWorkflow::Main::WorkflowSteps::CopyProviderProbeMappingFiles;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);
use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test, $undo) = @_;

  # get parameters
  my $inputTabFile = $self->getParamValue('inputTabFile');
  my $inputCdfFile = $self->getParamValue('inputCdfFile');
  my $inputNdfFile = $self->getParamValue('inputNdfFile');
  my $outputTabFile = $self->getParamValue('outputGeneProbeMappingTabFile');
  my $outputVendorFile = $self->getParamValue('outputGeneProbeMappingVendorFile');
  my $makeCdfFile = $self->getBooleanParamValue('makeCdfFile');
  my $makeNdfFile = $self->getBooleanParamValue('makeNdfFile');

  $self->error("Error:  parameters makeCdfFile and makeCdfFile cannot both be true") if $makeCdfFile && $makeNdfFile;
  $self->error("Input tab file '$inputTabFile' does not exist") unless -e $inputTabFile;
  my $workflowDataDir = $self->getWorkflowDataDir();

  my $cmd1 = "cp $workflowDataDir/$inputTabFile $workflowDataDir/$outputTabFile";
  my $cmd2;
  if ($makeCdfFile) {
      $self->error("Input cdf file '$inputCdfFile' does not exist") unless -e $inputCdfFile;
      $cmd2 = "cp $workflowDataDir/$inputCdfFile $workflowDataDir/$outputVendorFile";
  } elsif ($makeNdfFile) {
      $self->error("Input ndf file '$inputNdfFile' does not exist") unless -e $inputNdfFile;
      $cmd2 = "cp $workflowDataDir/$inputNdfFile $workflowDataDir/$outputVendorFile";
  } else {
    $cmd2 = "touch $workflowDataDir/$outputVendorFile";
  }

  if ($test) {
    $self->testInputFile('inputTabFile', "$inputTabFile");
    $self->testInputFile('inputCdfFile', "$inputCdfFile");
    $self->testInputFile('inputNdfFile', "$inputNdfFile");
    $self->runCmd(0, "echo test > $workflowDataDir/$outputTabFile");
    $self->runCmd(0, "echo test > $workflowDataDir/$outputVendorFile");
  }

  if ($undo) {
    $self->runCmd(0, "rm -f $workflowDataDir/$outputTabFile");
    $self->runCmd(0, "rm -f $workflowDataDir/$outputVendorFile");
  } else {
    $self->runCmd($test, $cmd1);
    $self->runCmd($test, $cmd2);
  }

}

sub getConfigDeclaration {
  return (
         # [name, default, description]
         # ['', '', ''],
         );
}


