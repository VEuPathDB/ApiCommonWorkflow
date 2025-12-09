package ApiCommonWorkflow::Main::WorkflowSteps::InsertNAFeatureImage;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test, $undo) = @_;

  my $workflowDataDir = $self->getWorkflowDataDir();
  my $geneImageTabFile = $self->getParamValue('geneImageTabFile');
  my $datasetName = $self->getParamValue('datasetName');
  my $datasetVersion = $self->getParamValue('datasetVersion');

  my $fileFullPath = "$workflowDataDir/$geneImageTabFile";

  my $args = "--file $fileFullPath --extDBName $datasetName --extDBVer $datasetVersion";

  $self->testInputFile('geneImageTabFile', "$fileFullPath");
  $self->runPlugin($test, $undo, "ApiCommonData::Load::Plugin::InsertNAFeatureImage", $args);

}

1;
