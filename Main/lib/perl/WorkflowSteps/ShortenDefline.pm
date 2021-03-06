package ApiCommonWorkflow::Main::WorkflowSteps::ShortenDefline;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);
use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test, $undo) = @_;

  # get parameters
  my $inputFile = $self->getParamValue('inputFile');
  my $outputFile = $self->getParamValue('outputFile');
  my $mappingFileRelativeToDownloadDir = $self->getParamValue('mappingFileRelativeToDownloadDir');

  my $downloadDir = $self->getSharedConfig('downloadDir');

  my $mappingFile = "$downloadDir/$mappingFileRelativeToDownloadDir";

  my $workflowDataDir = $self->getWorkflowDataDir();

  if ($undo) {
    $self->runCmd(0, "rm -f $workflowDataDir/$outputFile");
  }else {
    $self->testInputFile('inputFile', "$workflowDataDir/$inputFile");
      if ($test) {
	  $self->runCmd(0, "echo test > $workflowDataDir/$outputFile");
      }
    $self->runCmd($test, "shortenDefLine --inputFile $workflowDataDir/$inputFile --outputFile $workflowDataDir/$outputFile --taxonIdMappingFile '$mappingFile'");
  }
}

1;


