package ApiCommonWorkflow::Main::WorkflowSteps::MakeDerivedTables;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;


sub run {
  my ($self, $test, $undo) = @_;

  return if $test;

  my $organismAbbrev = $self->getParamValue('organismAbbrev');

  my $tables = $self->getParamValue('tables');

  my $gusHome = $self->getSharedConfig('gusHome');

  my $instance = $self->getGusInstanceName();

  my $username = $self->getGusDatabaseLogin();
  my $password = $self->getGusDatabasePassword();

  my $dblink = $self->getConfig('dblink');

  my $xmlConfigFileName="tmpConfigFile.xml";
  my $xmlConfigFileString=
"<?xml version='1.0'?>
<tuningProps>
  <username>$username</username>
  <password>$password</password>
  <schema>ApidbTuning</schema>
  <housekeepingSchema>apidb</housekeepingSchema>
  <dblink>$dblink</dblink>
  <logTable>apidb_r.TuningTableLog\@$dblink</logTable>
  <dbaEmail>eupath-admin\@pcbi.upenn.edu</dbaEmail>
  <fromEmail>tuningMgr\@pcbi.upenn.edu</fromEmail>
</tuningProps>
";
  my $stepDir = $self->getStepDir();
  open(F,">$stepDir/$xmlConfigFileName");
  print F $xmlConfigFileString;
  close F;

 my $cmd = "tuningManager -instance '$instance' -propFile $stepDir/$xmlConfigFileName -doUpdate -notifyEmail none -configFile ${gusHome}/lib/xml/tuningManager/apiTuningManager.xml  " ;
  
 if ($organismAbbrev){
   $cmd .= $self->prefixAndFilterValueCommandString($organismAbbrev, $test);
  }

 $cmd .= "-tables $tables  " if ($tables);

  if ($undo) {
     $self->runCmd(0, "echo Doing nothing for \"undo\" Tuning Manager.\n");  
  } else {
      $self->runCmd($test, $cmd);
  }
}


sub prefixAndFilterValueCommandString {
  my ($self, $organismAbbrev, $test) = @_;
  my $gusConfigFile = $self->getParamValue('gusConfigFile');
  $gusConfigFile = $self->getWorkflowDataDir() . "/$gusConfigFile";
 
  my $tuningTablePrefix = $self->getTuningTablePrefix($test, $organismAbbrev, $gusConfigFile);
    
  my $taxonId = $self->getOrganismInfo($test, $organismAbbrev, $gusConfigFile)->getTaxonId();

   return "-filterValue $taxonId -prefix '$tuningTablePrefix'  " ;
}


1;

