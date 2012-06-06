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

  my $baseFileName = basename($readsFile);

  my $args = "--studyName '$experimentName' --file $sampleMetaDataFile --sampleId $baseFileName --extDbRlsSpec '$snpExtDbRlsSpec'";

 unless ($test) {
   $self->runPlugin($test, $undo, "ApiCommonData::Load::Plugin::InsertSampleMetaData", $args);
  } 
}

sub getParamDeclaration {
  return ('experimentName',
          'sampleMetaDataFile',
          'readsFile',
          'snpExtDbRlsSpec'
         );
}

sub getConfigDeclaration {
  return (
      # [name, default, description]
     );
}

1;
