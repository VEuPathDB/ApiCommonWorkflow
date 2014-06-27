package ApiCommonWorkflow::Main::WorkflowSteps::MakeGfClientTaskInputDir;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test, $undo) = @_;

  # get parameter values
  my $taskInputDir = $self->getParamValue("taskInputDir");
  my $maxIntronSize = $self->getParamValue("maxIntronSize");
  my $queryFile = $self->getParamValue("queryFile");
  my $queryType = $self->getParamValue("queryType");
  my $targetDir = $self->getParamValue("targetDir");

  my $clusterServer = $self->getSharedConfig('clusterServer');
  my $taskSize = $self->getConfig("taskSize");

  my $clusterWorkflowDataDir = $self->getClusterWorkflowDataDir();
  my $workflowDataDir = $self->getWorkflowDataDir();
 
  $self->error("Parameter queryType=$queryType is invalid.  It must be either dna or protein") unless $queryType eq 'dna' || $queryType eq 'prot';

  if ($undo) {
    $self->runCmd(0,"rm -rf $workflowDataDir/$taskInputDir");
  }else {

    $self->testInputFile('queryFile', "$workflowDataDir/$queryFile");
    $self->testInputFile('targetDir', "$workflowDataDir/$targetDir");

    $self->runCmd(0,"mkdir -p $workflowDataDir/$taskInputDir");

    # make controller.prop file
    $self->makeDistribJobControllerPropFile($taskInputDir, 1, $taskSize,
				       "DJob::DistribJobTasks::GenomeAlignWithGfClientTask");
    # make task.prop file
    my $taskPropFile = "$workflowDataDir/$taskInputDir/task.prop";
    my $blatParams = $queryType eq 'prot' ? 'blatParams=-minScore=25 -minIdentity=20' : '';

    open(F, ">$taskPropFile") || die "Can't open task prop file '$taskPropFile' for writing";

    print F
"targetDirPath=$clusterWorkflowDataDir/$targetDir
queryPath=$clusterWorkflowDataDir/$queryFile
maxIntron=$maxIntronSize
queryType=$queryType
$blatParams
";
  close(F);
 }
}

1;

