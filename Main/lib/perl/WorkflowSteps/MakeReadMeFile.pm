package ApiCommonWorkflow::Main::WorkflowSteps::MakeReadMeFile;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);
use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test, $undo) = @_;

  # get parameters
  my $baseDir = $self->getParamValue('baseDir');
  my $outputFile = $self->getParamValue('outputFile');

  my $apiSiteFilesDir = $self->getSharedConfig('apiSiteFilesDir');

  my $cmd = "createReadMeFile.pl --baseDir $apiSiteFilesDir/$baseDir --outputFile $apiSiteFilesDir/$outputFile";

  if($undo){
    $self->runCmd(0, "rm -f $apiSiteFilesDir/$outputFile");
  }else{  
      if ($test) {
	  $self->runCmd(0, "echo test > $apiSiteFilesDir/$outputFile");
      }else {
	  $self->runCmd($test, $cmd);
      }
  }
}

sub getParamsDeclaration {
  return (
          'baseDir',
          'outputFile',
         );
}

sub getConfigDeclaration {
  return (
         # [name, default, description]
         # ['', '', ''],
         );
}

