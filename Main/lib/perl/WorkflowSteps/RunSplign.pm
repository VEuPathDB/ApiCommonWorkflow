package ApiCommonWorkflow::Main::WorkflowSteps::RunSplign;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;


sub run {
  my ($self, $test) = @_;

  my $queryFile = $self->getParamValue('queryFile');
  my $subjectFile = $self->getParamValue('subjectFile');
  my $outputFile = $self->getParamValue('outputFile');
  my $splignDir = $self->getParamValue('outputDir');

  my $splignPath = $self->getConfig('splignPath');
  my $ncbiBlastPath = $self->getConfig('ncbiBlastPath');

  my $workflowDataDir = $self->getWorkflowDataDir();

  $self->testInputFile('queryFile', "$workflowDataDir/$queryFile");
  $self->testInputFile('subjectFile', "$workflowDataDir/$subjectFile");

  if ($test) {
    $self->runCmd(0,"echo test > $workflowDataDir/$outputFile");
  }

  $self->runCmd($test, "${splignPath}/splign -mklds $splignDir");

  $self->runCmd($test, "${ncbiBlastPath}/formatdb -i $subjectFile -p F -o F");

  $self->runCmd($test, "${ncbiBlastPath}/megablast -i $queryFile -d $subjectFile -m 8 | sort -k 2,2 -k 1,1 > $splignDir/test.hit");

  $self->runCmd($test, "${splignPath}/splign -ldsdir $splignDir -hits $splignDir/test.hit > $outputFile");

}



sub restart {
}

sub undo {

}


1;
