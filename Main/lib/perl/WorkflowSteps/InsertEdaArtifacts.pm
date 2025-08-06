package ApiCommonWorkflow::Main::WorkflowSteps::InsertEdaArtifacts;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;


sub run {
  my ($self, $test, $undo) = @_;

  my $inputDirectory = $self->getParamValue('inputDirectory');
  my $outputDirectory = $self->getParamValue('outputDirectory');
  my $extDbRlsSpec = $self->getParamValue('extDbRlsSpec');
  my $gusConfigFile = $self->getParamValue('gusConfigFile');

  my $workflowDataDir = $self->getWorkflowDataDir();

  my $args = "--extDbRlsSpec '$extDbRlsSpec' --inputDirectory ${workflowDataDir}/${inputDirectory} --gusConfigFile ${workflowDataDir}/${gusConfgFile} --outputDirectory ${workflowDataDir}/${outputDirectory}";

  if($test) {
    $self->runCmd(0, "touch ${workflowDataDir}/${outputDirectory}");
  }

  if($undo) {
    $self->runCmd(0, "rm -r ${workflowDataDir}/${outputDirectory}");
  }

  $self->runPlugin($test, $undo, "ApiCommonData::Load::Plugin::InsertEdaStudyFromArtifacts", $args);
}

1;
