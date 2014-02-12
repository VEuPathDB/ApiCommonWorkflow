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
  my $readsFile = $self->getParamValue('readsFile');
  my $baseFileName = $readsFile ? basename($readsFile) : '';
  my $sampleIdStr  = $readsFile ? "--sampleId $baseFileName" :'';
  my $sampleExtDbRlsSpecTemplate = $self->getParamValue('sampleExtDbRlsSpecTemplate');
  my $sampleExtDbRlsSpecTemplateStr = $sampleExtDbRlsSpecTemplate ?  "--sampleExtDbRlsSpecTemplate \'$sampleExtDbRlsSpecTemplate\'" : '';
  my $isProfile = $self->getParamValue('isProfile');
  my $dataType = $self->getParamValue('dataType');
  $isProfile = $isProfile ?  '--isProfile' : '';

  

  my $args = "--studyName '$experimentName' --file $workflowDataDir/$sampleMetaDataFile --studyExtDbRlsSpec '$studyExtDbRlsSpec' --dataType '$dataType' $sampleExtDbRlsSpecTemplateStr  $sampleIdStr";

 unless ($test) {
   $self->runPlugin($test, $undo, "ApiCommonData::Load::Plugin::InsertStudyMetaData", $args);
  } 
}

sub getParamDeclaration {
  return ('experimentName',
          'sampleMetaDataFile',
          'readsFile',
          'sampleExtDbRlsSpecTemplate',
          'dataType',
          'studyExtDbRlsSpec',
         );
}

sub getConfigDeclaration {
  return (
      # [name, default, description]
     );
}

1;
