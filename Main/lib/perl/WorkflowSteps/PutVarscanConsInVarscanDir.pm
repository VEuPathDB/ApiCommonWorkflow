package ApiCommonWorkflow::Main::WorkflowSteps::PutVarscanConsInVarscanDir;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test, $undo) = @_;

  my $workflowDataDir = $self->getWorkflowDataDir();
  my $varscanConsDir = $self->getParamValue('varscanConsDir');
  my $strain = $self->getParamValue('strain');
  my $mainResultDir = $self->getParamValue('mainResultDir');

  # This is a workaround so <bld 22 workflows do not need to undo the cluster steps for hts snps
  #   NOTE:  The script for making the coverage.txt file is in DJob svn
  #  TODO:  After gus 4 migration ... remove the "else"
  my $cmd;
  if(-e "$workflowDataDir/$mainResultDir/result.coverage.txt" ) {
    $cmd = "ln -s $workflowDataDir/$mainResultDir/result.coverage.txt $workflowDataDir/$varscanConsDir/$strain.coverage.txt";
  }
  else {
    $cmd = "parseVarscanToCoverage.pl -file $workflowDataDir/$mainResultDir/result.varscan.cons.gz -outputFile $workflowDataDir/$varscanConsDir/$strain.coverage.txt";
  }

  my $undoCmd = "/bin/rm $workflowDataDir/$varscanConsDir/$strain.coverage.txt";

  if ($undo) {
    $self->runCmd(0, $undoCmd);
  } else {
    if ($test) {
      $self->runCmd(0,"echo $cmd > $workflowDataDir/$varscanConsDir/$strain.coverage.txt");
    }
    $self->runCmd($test,$cmd);
  }
}


1;
