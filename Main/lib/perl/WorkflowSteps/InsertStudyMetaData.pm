package ApiCommonWorkflow::Main::WorkflowSteps::InsertStudyMetaData;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;
use File::Basename;

sub run {
  my ($self, $test, $undo) = @_;

  my $workflowDataDir = $self->getWorkflowDataDir();
  my $experimentName = $self->getParamValue("experimentName");
  my $sampleMetaDataFile = $self->getParamValue('sampleMetaDataFile');
  my $studyExtDbRlsSpec = $self->getParamValue('studyExtDbRlsSpec');
  #my $readsFile = $self->getParamValue('readsFile');
  #my $baseFileName = $readsFile ? basename($readsFile) : '';
  #my $sampleIdStr  = $readsFile ? "--sampleId $baseFileName" :'';
  my $sampleIdStr  = "";
  my $sampleExtDbRlsSpecTemplate = $self->getParamValue('sampleExtDbRlsSpecTemplate');
  my $sampleExtDbRlsSpecTemplateStr = $sampleExtDbRlsSpecTemplate ?  "--sampleExtDbRlsSpecTemplate \'$sampleExtDbRlsSpecTemplate\'" : '';
  my $isProfile = $self->getParamValue('isProfile');
  $isProfile = $isProfile ?  '--isProfile' : '';

  

  my $args = "--studyName '$experimentName' --file $workflowDataDir/$sampleMetaDataFile --studyExtDbRlsSpec '$studyExtDbRlsSpec'  $sampleExtDbRlsSpecTemplateStr $isProfile $sampleIdStr";

  $self->runPlugin($test, $undo, "ApiCommonData::Load::Plugin::InsertStudyMetaData", $args);

}


1;
