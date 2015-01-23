package ApiCommonWorkflow::Main::WorkflowSteps::MakeRepeatMaskTaskInputDir;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);
use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test, $undo) = @_;

  # get parameters
  my $taskInputDir = $self->getParamValue('taskInputDir');
  my $seqsFile = $self->getParamValue('seqsFile');
  my $options = $self->getParamValue('options');
  my $organismAbbrev = $self->getParamValue('organismAbbrev');
  my $dangleMax = $self->getParamValue('dangleMax');
  my $trimDangling = $self->getParamValue('trimDangling');

  # get step properties
  my $clusterServer = $self->getSharedConfig('clusterServer');
  my $taskSize = $self->getConfig("taskSize");

  my $clusterWorkflowDataDir = $self->getClusterWorkflowDataDir();
  my $workflowDataDir = $self->getWorkflowDataDir();

  my $speciesName = $self->getOrganismInfo($test, $organismAbbrev)->getSpeciesName();

  # look for an optional property that provides info so we can override the species name
  # in the case that our native species name is not in repeat masker library.
  # we include in the property the speciesToOverride so that this property will only be
  # used if that species name is still being used for this species.  Eventually it will
  # probably be replaced by a species name recognized by repeat mask, in which case this
  # override will be ignored
  my $speciesOverride = $self->getConfig('speciesOverride',1);
  if ($speciesOverride) {
    my ($speciesToOverride, $speciesThatOverrides) = split(/,\s*/, $speciesOverride)
      || die "Config property speciesOverride has an invalid value: '$speciesOverride'.  It must be of the form 'speciesToOverride, speciesThatOverrides'\n";
    $speciesName = $speciesThatOverrides if $speciesName eq $speciesToOverride;
  }

  my $rmParamsFile = 'rmParams';
  my $localRmParamsFile = "$workflowDataDir/$taskInputDir/$rmParamsFile";
  
  $options .= " -species '$speciesName' -dir .";

  if ($undo) {
    $self->runCmd(0,"rm -rf $workflowDataDir/$taskInputDir");
  }else {

    $self->testInputFile('seqsFile', "$workflowDataDir/$seqsFile");

      $self->runCmd(0,"mkdir -p $workflowDataDir/$taskInputDir");

      # make controller.prop file
      $self->makeDistribJobControllerPropFile($taskInputDir, 1, $taskSize,
      			       "DJob::DistribJobTasks::RepeatMaskerTask");

      # make task.prop file
      my $taskPropFile = "$workflowDataDir/$taskInputDir/task.prop";
      open(F, ">$taskPropFile") || die "Can't open task prop file '$taskPropFile' for writing";

      print F 
"inputFilePath=$clusterWorkflowDataDir/$seqsFile
trimDangling=$trimDangling
dangleMax=$dangleMax
rmParamsFile=$rmParamsFile
";
      close(F);

       # make species file
       open(F, ">$localRmParamsFile") || die "Can't open species file '$localRmParamsFile' for writing";;
       print F "$options\n";
       close(F);

  }

}

1;
