package ApiCommonWorkflow::Main::WorkflowSteps::MakeDerivedTopLevelTables;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;


sub run {
  my ($self, $test, $undo) = @_;

  my $organismAbbrev = $self->getParamValue('organismAbbrev');

  #my $tables = "GeneAttributes,SequenceAttributes,FeatureLocation";

  my $tables = "SequencePieceClosure,FeatureLocation,GeneId,GeneAttributes,GenomicSequence,SequenceAttributes,TaxonSpecies";

  my $gusHome = $self->getSharedConfig('gusHome');
  my $instance = $self->getSharedConfig('instance');
  #Oracle table names can be no longer than 30 characters
  #instead of using the organismAbbrev for the prefix, we might need to use the primary key of that organism in the organism table, ie, organism_id. that should be no more than three characters.
  #4_char_prefix + 4_char_suffix --> table name <= 22 
  #table name must start w/ a letter, for example "p21_".
  my $organismId = $self->getOrganismInfo($test, $organismAbbrev)->getOrganismId();
  my $tuningTablePrefix = "P${organismId}_";

  my $apidbTuningPassword = $self->getConfig('apidbTuningPassword');
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
  my $cmd;

      $cmd = "tuningManager -prefix '$tuningTablePrefix' -instance '$instance' -propFile $stepDir/$xmlConfigFileName -doUpdate -notifyEmail none -tables $tables -configFile ${gusHome}/lib/xml/tuningManager.xml -filterValue 821459";


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


