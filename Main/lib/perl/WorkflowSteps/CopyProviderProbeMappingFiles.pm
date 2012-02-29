package ApiCommonWorkflow::Main::WorkflowSteps::CopyProviderProbeMappingFiles;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);
use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test, $undo) = @_;

  # get parameters
  my $inputDir = $self->getParamValue('inputDir');
  my $outputDir = $self->getParamValue('outputDir');
  my $providedMappingFileName = $self->getParamValue('providedMappingFileName');
  my $outputTabFile = $self->getParamValue('outputGeneProbeMappingTabFile');
  my $makeCdfFile = $self->getBooleanParamValue('makeCdfFile');
  my $makeNdfFile = $self->getBooleanParamValue('makeNdfFile');

  my $workflowDataDir = $self->getWorkflowDataDir();
  $self->error("Error:  parameters makeCdfFile and makeCdfFile cannot both be true") if $makeCdfFile && $makeNdfFile;
  $self->error("Input dir '$workflowDataDir/$inputDir' does not exist") unless (-d "$workflowDataDir/$inputDir");

  my $inputFile = "$workflowDataDir/$inputDir/$providedMappingFileName";

  my $cmd;
  if ($makeCdfFile || $makeNdfFile) {
      $self->error("Input provider file '$inputFile' does not exist") unless (-e "$inputFile");
      $cmd = "cp $inputFile $workflowDataDir/$providedMappingFileName";
  } else {
      $cmd = "cp $inputFile $workflowDataDir/$outputTabFile";
  }

  if ($test) {
      if ($makeCdfFile || $makeNdfFile) {
	  $self->runCmd(0, "echo test > $workflowDataDir/$providedMappingFileName");
      } else {
	  $self->runCmd(0, "echo test > $workflowDataDir/$outputTabFile");
      }
  }

  if ($undo) {
      if ($makeCdfFile || $makeNdfFile) {
	  $self->runCmd(0, "rm -f $workflowDataDir/$providedMappingFileName");
      } else {
	  $self->runCmd(0, "rm -f $workflowDataDir/$outputTabFile");
      }
  } else {
    $self->runCmd($test, $cmd);
  }

}

sub getConfigDeclaration {
  return (
         # [name, default, description]
         # ['', '', ''],
         );
}


