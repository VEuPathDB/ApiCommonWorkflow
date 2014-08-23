package ApiCommonWorkflow::Main::WorkflowSteps::MakeReadMeFile;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);
use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test, $undo) = @_;

  # get parameters
  my $baseDir = $self->getParamValue('baseDir');
  my $outputFile = $self->getParamValue('outputFile');

  my $cmd = "createReadMeFile.pl --baseDir $baseDir --outputFile $outputFile";

  if($undo){
    $self->runCmd(0, "rm -f $outputFile");
  }else{  
    if ($test) {
      $self->runCmd(0, "echo test > $outputFile");
    }
    $self->runCmd($test, $cmd);
  }
}

1;

