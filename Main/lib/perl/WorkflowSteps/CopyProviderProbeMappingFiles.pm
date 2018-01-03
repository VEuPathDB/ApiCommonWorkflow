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
      $cmd = "cp $inputFile $workflowDataDir/$outputDir/$providedMappingFileName";
  } else {
      $cmd = "cp $inputFile $workflowDataDir/$outputDir/$outputTabFile";
  }

  if ($test) {
      if ($makeCdfFile || $makeNdfFile) {
	  $self->runCmd(0, "echo test > $workflowDataDir/$outputDir/$providedMappingFileName");
      } else {
	  $self->runCmd(0, "echo test > $workflowDataDir/$outputDir/$outputTabFile");
      }
  }

  if ($undo) {
      if ($makeCdfFile || $makeNdfFile) {
	  $self->runCmd(0, "rm -f $workflowDataDir/$outputDir/$providedMappingFileName");
      } else {
	  $self->runCmd(0, "rm -f $workflowDataDir/$outputDir/$outputTabFile");
      }
  } else {
    $self->runCmd($test, $cmd);
  }

}

1;
