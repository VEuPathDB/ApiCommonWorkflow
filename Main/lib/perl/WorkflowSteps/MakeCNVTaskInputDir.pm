package ApiCommonWorkflow::Main::WorkflowSteps::MakeCNVTaskInputDir;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use warnings;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test, $undo) = @_;

  # get parameter values
  my $taskInputDir = $self->getParamValue("taskInputDir");
  my $genomicSeqsFile = $self->getParamValue("genomicSeqsFile");
  my $bamFile = $self->getParamValue("bamFile");
  my $snpsClusterDir = $self->getParamValue("snpsClusterDir");
  my $gtfFile = $self->getParamValue("gtfFile");
  my $geneFootprintFile = $self -> getParamValue("geneFootprintFile");
  my $samtoolsIndex = $self->getParamValue("samtoolsIndex");
  my $sampleName = $self->getParamValue("sampleName");
  my $window = $self->getParamValue("window");

  my $taskSize = $self->getConfig("taskSize");
  my $clusterWorkflowDataDir = $self->getClusterWorkflowDataDir();
  my $workflowDataDir = $self->getWorkflowDataDir();

  if ($undo) {
    $self->runCmd(0, "rm -rf $workflowDataDir/$taskInputDir/");
  }else {

    $self->testInputFile('readsFile', "$workflowDataDir/$gtfFile");

    $self->runCmd(0,"mkdir -p $workflowDataDir/$taskInputDir");

    # make controller.prop file
    $self->makeDistribJobControllerPropFile($taskInputDir, 1, $taskSize,
        "DJob::DistribJobTasks::CNVTasks", 0);
 
    # make task.prop file
    my $taskPropFile = "$workflowDataDir/$taskInputDir/task.prop";
    open(F, ">$taskPropFile") || die "Can't open task prop file '$taskPropFile' for writing";

    my $taskPropFileContent="
        genomicSeqsFile=$clusterWorkflowDataDir/$genomicSeqsFile
        bamFile=$clusterWorkflowDataDir/$snpsClusterDir/$bamFile
        gtfFile=$clusterWorkflowDataDir/$gtfFile
        geneFootprintFile=$clusterWorkflowDataDir/$geneFootprintFile
        samtoolsIndex=$clusterWorkflowDataDir/$samtoolsIndex
        sampleName=$sampleName
        window=$window
        snpsClusterDir=$clusterWorkflowDataDir/$snpsClusterDir
        ";
	
      

    print F "$taskPropFileContent\n";
    close(F);
  }
}

1;
