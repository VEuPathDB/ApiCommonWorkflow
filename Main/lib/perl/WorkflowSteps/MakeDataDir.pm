package ApiCommonWorkflow::Main::WorkflowSteps::MakeDataDir;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);
use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

## make a dir relative to the workflow's data dir

sub run {
  my ($self, $test, $undo) = @_;

  # get parameters
  my $dataDir = $self->getParamValue('dataDir');

  my $localDataDir = $self->getLocalDataDir();

  if($undo){

      $self->runCmd(0, "rm -fr $localDataDir/$dataDir");

  }else{

      $self->runCmd(0, "mkdir -p $localDataDir/$dataDir");

  }


}

sub getParamsDeclaration {
  return (
          'dataDir',
         );
}

sub getConfigDeclaration {
  return (
         # [name, default, description]
         # ['', '', ''],
         );
}


