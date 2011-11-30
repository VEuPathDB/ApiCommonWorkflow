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
  my $rmPath = $self->getConfig("$clusterServer.rmPath");

  my $clusterWorkflowDataDir = $self->getClusterWorkflowDataDir();
  my $workflowDataDir = $self->getWorkflowDataDir();

  my $speciesName = $self->getOrganismInfo($test, $organismAbbrev)->getSpeciesName();

  my $rmParamsFile = 'rmParams';
  my $localRmParamsFile = "$workflowDataDir/$taskInputDir/$rmParamsFile";
  
  $options .= " -species '$speciesName' -dir .";

  if ($undo) {
    $self->runCmd(0,"rm -rf $workflowDataDir/$taskInputDir");
  }else {
      if ($test) {
	  $self->testInputFile('seqsFile', "$workflowDataDir/$seqsFile");
      }
      $self->runCmd(0,"mkdir -p $workflowDataDir/$taskInputDir");

      # make controller.prop file
      $self->makeDistribJobControllerPropFile($taskInputDir, 1, $taskSize,
      			       "DJob::DistribJobTasks::RepeatMaskerTask");

      # make task.prop file
      my $taskPropFile = "$workflowDataDir/$taskInputDir/task.prop";
      open(F, ">$taskPropFile") || die "Can't open task prop file '$taskPropFile' for writing";

      print F 
"rmPath=$rmPath
inputFilePath=$clusterWorkflowDataDir/$seqsFile
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

sub getConfigDeclaration {
  return (
         # [name, default, description]
         # ['', '', ''],
         );
}

