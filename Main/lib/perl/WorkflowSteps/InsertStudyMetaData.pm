package ApiCommonWorkflow::Main::WorkflowSteps::InsertStudyMetaData;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;
use File::Basename;

sub run {
  my ($self, $test, $undo) = @_;

  my $experimentName = $self->getParamValue("experimentName");
  my $sampleMetaDataFile = $self->getParamValue('sampleMetaDataFile');
  my $readsFile = $self->getParamValue('readsFile');
  my $samplesExtDbRlsSpec = $self->getParamValue('sampleExtDbRlsSpec');
  my $samplesExtDbRlsSpecStr = $samplesExtDbRlsSpec ?  "--samplesExtDbRlsSpec \'$samplesExtDbRlsSpec\'" : '';
  my $workflowDataDir = $self->getWorkflowDataDir();
  my $baseFileName = basename($readsFile);
  my $sampleExtDbRlsSpecTemplate = $self->getParamValue('sampleExtDbRlsSpecTemplate');
  my $sampleExtDbRlsSpecTemplateStr = $sampleExtDbRlsSpecTemplate ?  "--sampleExtDbRlsSpecTemplate \'$sampleExtDbRlsSpecTemplate\'" : '';
  my $isProfile = $self->getParamValue('isProfile');
  $isProfile = $isProfile ?  '--isProfile' : '';
  my $studyExtDbRlsSpec = $self->getParamValue('studyExtDbRlsSpec');
  my $studyExtDbRlsSpecStr = $studyExtDbRlsSpec ?  "--studyExtDbRlsSpec \'$studyExtDbRlsSpec\'" : '';
  

  my $args = "--studyName '$experimentName' --file $workflowDataDir/$sampleMetaDataFile --sampleId $baseFileName $studyExtDbRlsSpecStr $samplesExtDbRlsSpecStr  $sampleExtDbRlsSpecTemplateStr $isProfile $samplesExtDbRlsSpecStr";

 unless ($test) {
   $self->runPlugin($test, $undo, "ApiCommonData::Load::Plugin::InsertStudyMetaData", $args);
  } 
}

sub getParamDeclaration {
  return ('experimentName',
          'sampleMetaDataFile',
          'readsFile',
          'sampleExtDbRlsSpec',
          'sampleExtDbRlsSpecTemplate',
          'isProfile',
          'studyExtDbRlsSpec',
         );
}

sub getConfigDeclaration {
  return (
      # [name, default, description]
     );
}

1;
