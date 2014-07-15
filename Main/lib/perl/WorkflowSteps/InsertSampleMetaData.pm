package ApiCommonWorkflow::Main::WorkflowSteps::InsertSampleMetaData;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;
use File::Basename;

sub run {
  my ($self, $test, $undo) = @_;

  my $experimentName = $self->getParamValue("experimentName");
  my $sampleMetaDataFile = $self->getParamValue('sampleMetaDataFile');
  my $readsFile = $self->getParamValue('readsFile');
  my $snpExtDbRlsSpec = $self->getParamValue('snpExtDbRlsSpec');
  my $workflowDataDir = $self->getWorkflowDataDir();
  my $baseFileName = basename($readsFile);

  my $args = "--studyName '$experimentName' --file $workflowDataDir/$sampleMetaDataFile --sampleId $baseFileName --sampleExtDbRlsSpec '$snpExtDbRlsSpec'";


   $self->runPlugin($test, $undo, "ApiCommonData::Load::Plugin::InsertSampleMetaData", $args);

}

1;
