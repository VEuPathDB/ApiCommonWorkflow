package ApiCommonWorkflow::Main::WorkflowSteps::ClearWdkCache;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;


sub run {
  my ($self, $test, $undo) = @_;

  my $model = $self->getParamValue('model');

  my $cmd = "wdkCache -model $model -reset";


  if ($undo){
     $self->runCmd(0, "echo Doing nothing for \"undo\" clear WDK Cache.\n");  
  }else{
      if ($test) {
      }else {
	  $self->runCmd($test, $cmd);
      }
  }


}

sub getParamsDeclaration {
  return (
	  'model',
	 );
}

sub getConfigDeclaration {
  return (
	  # [name, default, description]
	 );
}


