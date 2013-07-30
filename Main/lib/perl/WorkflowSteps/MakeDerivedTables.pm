package ApiCommonWorkflow::Main::WorkflowSteps::MakeDerivedTables;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;


sub run {
  my ($self, $test, $undo) = @_;

  my $organismAbbrev = $self->getParamValue('organismAbbrev');
  my $tables = $self->getParamValue('tables');

  my $gusHome = $self->getSharedConfig('gusHome');

  my $instance = $self->getGusInstanceName();

  my $tuningTablePrefix = $self->getTuningTablePrefix($organismAbbrev, $test);

  my $apidbTuningPassword = $self->getConfig('apidbTuningPassword');

  my $dblink = $self->getConfig('dblink');

  my $xmlConfigFileName="tmpConfigFile.xml";
  my $xmlConfigFileString=
"<?xml version='1.0'?>
<property>
<password>$apidbTuningPassword</password>
<schema>ApiDBTuning</schema>
<dblink>$dblink</dblink>
</property>
";
  my $stepDir = $self->getStepDir();
  open(F,">$stepDir/$xmlConfigFileName");
  print F $xmlConfigFileString;
  close F;

  my $taxonId = $self->getOrganismInfo($test, $organismAbbrev)->getTaxonId();

  my $cmd = "tuningManager -prefix '$tuningTablePrefix' -instance '$instance' -propFile $stepDir/$xmlConfigFileName -doUpdate -notifyEmail none -tables $tables -configFile ${gusHome}/lib/xml/tuningManager.xml -filterValue $taxonId ";


  if ($undo) {
     $self->runCmd(0, "echo Doing nothing for \"undo\" Tuning Manager.\n");  
  } else {
      $self->runCmd($test, $cmd);
  }
}



