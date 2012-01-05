package ApiCommonWorkflow::Main::WorkflowSteps::MakeDerivedGeneIdTable;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;


sub run {
  my ($self, $test, $undo) = @_;

  my $tables = "GeneId";
  my $organismAbbrev = $self->getParamValue('organismAbbrev');

  my $gusHome = $self->getSharedConfig('gusHome');
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

      $cmd = "tuningManager -prefix '${organismAbbrev}_' --instance '$instance' --propFile $xmlConfigFileName --doUpdate --notifyEmail none --tables $tables";
              tuningManager -prefix {organism_abbrev}  -tables SequencePieceClosure,FeatureLocation,GeneId,GeneAttributes,GenomicSequence,SequenceAttributes,TaxonSpecies -filterValue 821459 -doUpdate -configFile {XML file} -instance {instance} -propfile ~/tm.props -notifyEmail none
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


