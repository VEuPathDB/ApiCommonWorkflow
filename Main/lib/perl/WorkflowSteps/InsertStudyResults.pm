package ApiCommonWorkflow::Main::WorkflowSteps::InsertStudyResults;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;


sub run {
  my ($self, $test, $undo) = @_;

  my $configFile = $self->getParamValue('configFile');

  my $inputDir = $self->getParamValue('inputDir');

  my $extDbRlsSpec = $self->getParamValue('extDbRlsSpec');

  my $studyName = $self->getParamValue('studyName');

  my $workflowDataDir = $self->getWorkflowDataDir();

  my $args = "--inputDir $workflowDataDir/$inputDir --configFile $workflowDataDir/$configFile --extDbSpec '$extDbRlsSpec' --studyName '$studyName'";

  

    #$self->testInputFile('inputDir', "$workflowDataDir/$inputDir");
    #$self->testInputFile('configFile', "$workflowDataDir/$configFile");


  $self->runPlugin($test, $undo, "ApiCommonData::Load::Plugin::InsertStudyResults", $args);

}


1;
