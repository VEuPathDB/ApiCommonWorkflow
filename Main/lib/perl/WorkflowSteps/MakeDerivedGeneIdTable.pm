package ApiCommonWorkflow::Main::WorkflowSteps::MakeDerivedGeneIdTable;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;


sub run {
  my ($self, $test, $undo) = @_;

  my $tables = "GeneId";
  my $prefix = $self->getParamValue('prefix');

  my $gusHome = $self->getSharedConfig('gusHome');
  my $email = $self->getSharedConfig('email');
  my $instance = $self->getSharedConfig('instance');

  my $apidbTuningPassword = $self->getConfig('apidbTuningPassword');
  my $xmlConfigFileName="tmpConfigFile.xml";
  my $xmlConfigFileString=
"<?xml version='1.0'?>
<property>
<password>$apidbTuningPassword</password>
<schema>ApiDBTuning</schema>
</property>
";
  open(F,">$xmlConfigFileName");
  print F $xmlConfigFileString;
  close F;
  my $cmd;

      $cmd = "tuningManager -prefix '$prefix' --instance '$instance' --propFile $xmlConfigFileName --doUpdate --notifyEmail '$email' --tables $tables";


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


