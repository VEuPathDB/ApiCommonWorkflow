package ApiCommonWorkflow::Main::WorkflowSteps::RunTuningManager;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;


sub run {
  my ($self, $test, $undo) = @_;

  my $gusHome = $self->getSharedConfig('gusHome');
  my $dbaEmail = $self->getSharedConfig('dbaEmail');
  my $instance = $self->getSharedConfig('instance');

  my $apidbPassword = $self->getConfig('apidbPassword');
  my $xmlConfigFileName="tmpConfigFile.xml";
  my $xmlConfigFileString=
"
<tuningProps>
  <password>$apidbPassword</password>
  <dbaEmail>$dbaEmail</dbaEmail>
  <dblink>alt.login_comment</dblink>
  <schema>ApidbTuning</schema>
</tuningProps>
";
  open(F,">$xmlConfigFileName");
  print F $xmlConfigFileString;
  close F;
  my $cmd;

      $cmd = "tuningManager --instance '$instance' --propFile $xmlConfigFileName --doUpdate --tables 'GeneId,GeneAttributes,FeatureLocation' --cleanupAge 0";


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


