package ApiCommonWorkflow::Main::WorkflowSteps::RunGffDump;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);
use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;


sub run {
  my ($self, $test, $undo) = @_;

  # get parameters
  my $apiSiteFilesDir = $self->getSharedConfig('apiSiteFilesDir');
  my $downloadSiteDataDir = $self->getParamValue('downloadSiteDataDir');

  my $outputFile = $self->getParamValue('outputFile');
  my $organismName = $self->getParamValue('organismName');
  my $organismFullName = $self->getParamValue('organismFullName');
  my $projectDB = $self->getParamValue('projectDB');

  my $cmd1 = "wdkCache -model $projectDB  -recreate";
  my $cmd2 = "gffDump  -model $projectDB  -organism \"$organismFullName\"  -dir $apiSiteFilesDir/$outputFile";

  if ($test) {
      $self->runCmd(0, "echo test > $apiSiteFilesDir/$outputFile");
  } elsif($undo) {
    $self->runCmd(0, "rm -f $apiSiteFilesDir/$downloadSiteDataDir/$outputFile");
  }else {
      $self->runCmd($test, $cmd1);
      $self->runCmd($test, $cmd2);
  }

}

sub getParamsDeclaration {
  return (
          'outputFile',
          'organismName',
          'organismFullName',
          'projectDB',
	  'downloadSiteDataDir',
         );
}

sub getConfigDeclaration {
  return (
         # [name, default, description]
         # ['', '', ''],
         );
}


