package ApiCommonWorkflow::Main::WorkflowSteps::SnpMergeLocationMaps;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);
use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test, $undo) = @_;

  my $globInput = $self->getParamValue('globInput');
  my $outputFile = $self->getParamValue('outputFile');
  my $organismAbbrev = $self->getParamValue('organismAbbrev');
  my $workflowDataDir = $self->getWorkflowDataDir();

  my @inputs = glob "$workflowDataDir/$globInput";

  my $readFreq = $self->getParamValue("readFrequency");
  my $hsssDir = $self->getParamValue("hsssDir");

  my $websiteFilesDir = $self->getWebsiteFilesDir($test);
  my $webServicesRelativeDir = $self->getParamValue('relativeWebServicesDir');
  my $organismNameForFiles = $self->getOrganismInfo($test, $organismAbbrev)->getNameForFiles();
  my $hssDir = "$websiteFilesDir/$webServicesRelativeDir/$organismNameForFiles/$hsssDir/readFreq$readFreq";

  if ($undo) {
    $self->runCmd(0, "rm -f $hssDir/$outputFile");
  }
  else {
    foreach my $inputFile (@inputs) {
	$self->testInputFile('inputFile', "$inputFile");
    }
    if($test) {
      $self->runCmd(0, "echo test > $hssDir/$outputFile");
    } 

    $self->runCmd($test, "cat $workflowDataDir/$globInput | sort -k 2,2 -k 3,3n > $hssDir/$outputFile");
  }
}

1;
