package ApiCommonWorkflow::Main::WorkflowSteps::RunTuningManager;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;


sub run {
  my ($self, $test, $undo) = @_;

  my $gusHome = $self->getGlobalConfig('gusHome');
  my $email = $self->getGlobalConfig('email');
  my $instance = $self->getGlobalConfig('instance');

  my $apidbPassword = $self->getConfig('apidbPassword');
  my $xmlConfigFileName="tmpConfigFile.xml";
  my $xmlConfigFileString=
"<?xml version='1.0'?>
<property>
<password>$apidbPassword</password>
<username>apidb</username>
</property>
";
  open(F,">$xmlConfigFileName");
  print F $xmlConfigFileString;
  close F;
  my $cmd;

      $cmd = "tuningManager --instance '$instance' --propFile $xmlConfigFileName --doUpdate --notifyEmail '$email' --cleanupAge 0";


  if ($undo){
     $self->runCmd(0, "echo Doing nothing for \"undo\" Tuning Manager.\n");  
  }else{
      if ($test) {
      }else {
	  $self->runCmd($test, $cmd);
      }
  }


}

sub getParamsDeclaration {
  return (
	 );
}

sub getConfigDeclaration {
  return (
	  # [name, default, description]
	 );
}


