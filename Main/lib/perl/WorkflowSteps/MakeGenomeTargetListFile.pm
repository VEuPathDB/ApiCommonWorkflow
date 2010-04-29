package ApiCommonWorkflow::Main::WorkflowSteps::MakeGenomeTargetListFile;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test, $undo) = @_;

  # get parameter values
  my $targetDir = $self->getParamValue("targetDir");

  my $clusterWorkflowDataDir = $self->getClusterWorkflowDataDir();
  my $workflowDataDir = $self->getWorkflowDataDir();

  if ($undo) {
    $self->runCmd(0,"rm -rf $workflowDataDir/targetList");
  }else {

   if ($test) {
        $self->testInputFile('targetDir', "$workflowDataDir/$targetDir");
    }

    $self->makeGenomeTargetListFile("$workflowDataDir/$targetDir",
				    "$workflowDataDir/targetList",
				    "$clusterWorkflowDataDir/$targetDir");
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
  return ( 'targetDir',
	 );
}

sub getConfigDeclaration {
  return (
	  # [name, default, description]
	 );
}

