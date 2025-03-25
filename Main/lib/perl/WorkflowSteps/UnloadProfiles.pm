package ApiCommonWorkflow::Main::WorkflowSteps::UnloadProfiles;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;


sub run {
  my ($self, $test, $undo) = @_;

  my $datasetName = $self->getParamValue('datasetName');
  my $gusConfigFile = $self->getGusConfigFile();

  if ($undo) {
    #This class doesn't do anything in undo mode
  } else {
    if ($test) {
        $self->runCmd($test, "undoRnaSeqProfiles.pl --datasetName $datasetName"); # run without commit flag in test mode
    } else {
        $self->runCmd($test,"undoRnaSeqProfiles.pl --datasetName $datasetName --gusConfigFile $gusConfigFile --commit");
    }
  }
}

1;
