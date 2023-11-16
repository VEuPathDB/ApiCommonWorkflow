package ApiCommonWorkflow::Main::WorkflowSteps::ProcessSequenceVariations;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);
use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

use File::Basename;

sub run {
  my ($self, $test, $undo) = @_;



  my $newSampleFile = $self->getParamValue('newSampleFile');
  my $cacheFile = $self->getParamValue('cacheFile');
  my $undoneStrainsFile = $self->getParamValue('undoneStrainsFile');
  my $varscanConsDir = $self->getParamValue('varscanConsDir');
  my $genomeExtDbRlsSpec = $self->getParamValue('genomeExtDbRlsSpec');

  my $snpExtDbRlsSpec = $self->getParamValue('snpExtDbRlsSpec');

  my $isLegacy = $self->getBooleanParamValue('isLegacy');

  my $organismAbbrev = $self->getParamValue('organismAbbrev');

  my $organismStrain = $self->getOrganismInfo($test, $organismAbbrev)->getStrainAbbrev();

  my $gusConfigFile = $self->getGusConfigFile();

  unless($organismStrain) {
    $self->error("Strain Abbreviation for the reference [$organismAbbrev] was not defined");   
  }

  my $workflowDataDir = $self->getWorkflowDataDir();

  my $dirname = dirname("$workflowDataDir/$newSampleFile");

  my $cmd = "processSequenceVariations.pl --new_sample_file $workflowDataDir/$newSampleFile --cache_file $workflowDataDir/$cacheFile --undone_strains_file $workflowDataDir/$undoneStrainsFile --transcript_extdb_spec '$genomeExtDbRlsSpec' --organism_abbrev $organismAbbrev --reference_strain $organismStrain  --extdb_spec '$snpExtDbRlsSpec' --gusConfigFile $gusConfigFile";

  if($isLegacy) {
      $cmd .= " --is_legacy_variations --clean_cache";
  }
  else {
      $cmd .= " --varscan_directory $workflowDataDir/$varscanConsDir";
  }

  unless($undo) {
    $self->testInputFile('newSampleFile', "$workflowDataDir/$newSampleFile");
    if($test) {
      $self->runCmd(0, "echo test > $workflowDataDir/$cacheFile");
      $self->runCmd(0, "echo test > $dirname/snpFeature.dat");
    }
    $self->runCmd($test, $cmd);
  }else{
      $self->runCmd(0, "rm -f $dirname/snpFeature.dat");     
  }
}

1;
