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
  my $targetDir = $self->getParamValue("targetDir");

  my $taskSize = $self->getConfig('taskSize');
  my $gaBinPath = $self->getConfig('gaBinPath');

  my $clusterWorkflowDataDir = $self->getClusterWorkflowDataDir();
  my $workflowDataDir = $self->getWorkflowDataDir();

  if ($undo) {
    $self->runCmd(0,"rm -rf $workflowDataDir/$taskInputDir");
  }else {

   if ($test) {
        $self->testInputFile('queryFile', "$workflowDataDir/$queryFile");
        $self->testInputFile('targetDir', "$workflowDataDir/$targetDir");
    }

    $self->runCmd(0,"mkdir -p $workflowDataDir/$taskInputDir");

    # make controller.prop file
    $self->makeClusterControllerPropFile($taskInputDir, 1, $taskSize,
				       "DJob::DistribJobTasks::GenomeAlignWithGfClientTask");
    # make task.prop file
    my $taskPropFile = "$workflowDataDir/$taskInputDir/task.prop";
    open(F, ">$taskPropFile") || die "Can't open task prop file '$taskPropFile' for writing";

    print F
"gaBinPath=$gaBinPath
targetDirPath=$clusterWorkflowDataDir/$targetDir/nib
queryPath=$clusterWorkflowDataDir/$queryFile
nodePort=5550
maxIntron=$maxIntronSize
";
  close(F);

    $self->makeGenomeTargetListFile("$workflowDataDir/$targetDir",
				    "$workflowDataDir/$taskInputDir/targetList",
				    "$clusterWorkflowDataDir/$targetDir");

    #&runCmd($test, "chmod -R g+w $workflowDataDir/similarity/$queryName-$subjectName");
  }
}

sub makeGenomeTargetListFile {
    my ($self, $inputDir, $outputFile, $clusterOutputDir) = @_; 

    open(F, ">$outputFile") || die "Can't open $outputFile for writing";

    opendir(D,$inputDir) || die "Can't open directory, $inputDir";

    while(my $file = readdir(D)) {
      next() if ($file =~ /^\./);
      print F "$clusterOutputDir/$file\n";
    }

    closedir(D);
    close(F);
}


sub getParamsDeclaration {
  return ('taskInputDir',
	  'queryFile',
	  'targetDir',
	  'maxIntronSize',
	 );
}

sub getConfigDeclaration {
  return (
	  # [name, default, description]
	  ['taskSize', "", ""],
	  ['gaBinPath', "", ""],
	 );
}

