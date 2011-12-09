package ApiCommonWorkflow::Main::WorkflowSteps::MakeGfClientTaskInputDirNew;

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
  my $gaBinPath = $self->getConfig("$clusterServer.gaBinPath");

  my $clusterWorkflowDataDir = $self->getClusterWorkflowDataDir();
  my $workflowDataDir = $self->getWorkflowDataDir();
 
  $self->error("Parameter queryType=$queryType is invalid.  It must be either dna or protein") unless $queryType eq 'dna' || $queryType eq 'protein';

  if ($undo) {
    $self->runCmd(0,"rm -rf $workflowDataDir/$taskInputDir");
  }else {

   if ($test) {
        $self->testInputFile('queryFile', "$workflowDataDir/$queryFile");
        $self->testInputFile('targetDir', "$workflowDataDir/$targetDir");
    }

    $self->runCmd(0,"mkdir -p $workflowDataDir/$taskInputDir");

    # make controller.prop file
    $self->makeDistribJobControllerPropFile($taskInputDir, 1, $taskSize,
				       "DJob::DistribJobTasks::GenomeAlignWithGfClientTask");
    # make task.prop file
    my $taskPropFile = "$workflowDataDir/$taskInputDir/task.prop";
    open(F, ">$taskPropFile") || die "Can't open task prop file '$taskPropFile' for writing";

   my $blatParams = $queryType eq 'protein' ? 'blatParams=-minScore=25 -minIdentity=20' : '';
    print F
"gaBinPath=$gaBinPath
targetDirPath=$clusterWorkflowDataDir/$targetDir/nib
queryPath=$clusterWorkflowDataDir/$queryFile
nodePort=5550
maxIntron=$maxIntronSize
queryType=$queryType
$blatParams
";
  close(F);
 }
}

sub getConfigDeclaration {
  return (
	  # [name, default, description]
	  ['taskSize', "", ""],
	  ['gaBinPath', "", ""],
	 );
}

