package ApiCommonWorkflow::Main::WorkflowSteps::MakeDerivedGeneIdTable;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;


sub run {
  my ($self, $test, $undo) = @_;

  my $tables = "GeneId";
  my $organismAbbrev = $self->getParamValue('organismAbbrev');

  my $gusHome = $self->getSharedConfig('gusHome');

  my $apidbTuningPassword = $self->getConfig('apidbTuningPassword');

  my $instance = $self->getGusInstanceName();

  my $xmlConfigFileName="tmpConfigFile.xml";
  my $xmlConfigFileString=
"<?xml version='1.0'?>
<property>
<password>$apidbTuningPassword</password>
<schema>ApiDBTuning</schema>
</property>
";
  my $stepDir = $self->getStepDir();
  open(F,">$stepDir/$xmlConfigFileName");
  print F $xmlConfigFileString;
  close F;
  my $tmPrefix = $self->getTuningTablePrefix($organismAbbrev, $test);
  my $cmd = "tuningManager -prefix ${tmPrefix} --instance '$instance' --propFile $stepDir/$xmlConfigFileName --doUpdate --notifyEmail none --tables $tables -configFile ${gusHome}/lib/xml/tuningManager.xml";
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
  return ('organismAbbrev',
	 );
}

sub getConfigDeclaration {
  return (
	  # [name, default, description]
	 );
}


